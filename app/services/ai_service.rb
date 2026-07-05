require "net/http"
require "json"
require "digest"
require "timeout"

# AiService – Central AI gateway for CareerAI.
# ALL AI requests must flow through this service.
#
# Safety guarantees:
#   1. Credit check BEFORE any work
#   2. Credits deducted ONLY inside a committed DB transaction, AFTER a
#      successful provider response — never on timeout, error, or rollback
#   3. One lock per user/resume/feature (no fingerprint in key) so
#      cross-tab concurrent requests are properly blocked
#   4. Absolute 30-second wall-clock Timeout::timeout wraps the ENTIRE
#      provider call + retry loop — no request can hang forever
#   5. Maximum 2 provider retries (transient errors only); non-retryable
#      errors break immediately
#   6. Lock is ALWAYS released in ensure, even on timeout or exception
#   7. Every lifecycle state is logged (queued → processing → success/fail)
class AiService
  # ─── Error hierarchy ────────────────────────────────────────────────────
  class InsufficientCreditsError < StandardError; end
  class ConfigurationError       < StandardError; end
  class InvalidInputError        < StandardError; end
  class ApiError                 < StandardError; end
  class DuplicateRequestError    < StandardError; end
  class RequestTooLargeError     < StandardError; end
  class AuthenticationError      < StandardError; end
  class RateLimitError           < StandardError; end
  class ProviderUnavailableError < StandardError; end
  class TimeoutError             < StandardError; end
  class InvalidRequestError      < StandardError; end

  # ─── Constants ──────────────────────────────────────────────────────────
  CONFIG    = YAML.load_file(Rails.root.join("config", "ai_features.yml"))
  AI_CONFIG = YAML.safe_load(
    ERB.new(File.read(Rails.root.join("config", "ai.yml"))).result,
    aliases: true
  )[Rails.env] || {}

  # The absolute maximum seconds any single generation may take.
  # Provider timeouts (25s read + 8s open) fire INSIDE this budget.
  # The lock TTL is this + a small buffer so stale locks expire automatically.
  GENERATION_TIMEOUT = 30 # seconds
  LOCK_TTL           = (GENERATION_TIMEOUT + 15).seconds # 45s

  MAX_RETRIES            = 2  # provider retries inside ONE HTTP request
  MAX_INSTRUCTIONS_WORDS = 200
  MAX_RESUME_TEXT_CHARS  = 20_000
  MAX_INSTRUCTIONS_CHARS = 2_000

  # Boot-time provider announcement — visible in logs on every Rails start.
  # This is the single source of truth for which provider will handle requests.
  Rails.logger.info do
    selected = AI_CONFIG["provider"] || "stub"
    key_present = case selected
    when "groq"       then ENV["GROQ_API_KEY"].present?
    when "gemini"     then ENV["GEMINI_API_KEY"].present?
    when "openrouter" then ENV["OPENROUTER_API_KEY"].present?
    else false
    end
    status = key_present ? "KEY_PRESENT ✓" : "NO_KEY ✗ (stub fallback will occur)"
    "[AiService] PROVIDER=#{selected.upcase} #{status} env=#{Rails.env}"
  end

  # ─── Primary entrypoint ─────────────────────────────────────────────────
  def self.generate(user:, resume:, feature:, context: {}, instructions: "", force_new: false, request_meta: {})
    feature_config = CONFIG.dig("features", feature.to_s)
    raise ConfigurationError, "Unknown AI feature: #{feature}" unless feature_config

    credits_required = feature_config["credits"].to_i
    word_limit       = feature_config["word_limit"].to_i
    prompt_version   = feature_config["prompt_version"]
    cache_enabled    = feature_config["cache_enabled"]
    provider_name    = AI_CONFIG["provider"] || "stub"
    model            = AI_CONFIG.dig("providers", provider_name, "model") || CONFIG.dig("default", "model")
    temperature      = CONFIG.dig("default", "temperature")
    max_tokens       = CONFIG.dig("default", "max_output_tokens")

    # ── 1. Sanitize + validate instructions ───────────────────────────────
    instructions = sanitize_instructions(instructions)
    validate_request_size!(instructions, context[:resume_content])

    # ── 2. Credit check ───────────────────────────────────────────────────
    remaining = user.remaining_credits.to_i
    raise InsufficientCreditsError,
      "Not enough AI credits. You need #{credits_required} credit(s) but have #{remaining}." \
      if remaining < credits_required

    # ── 2.5. Inject previous_output for iterative improvement ─────────────
    if context[:previous_output].present?
      instructions = "Previous AI Output to improve:\n#{context[:previous_output]}\n\nNew Instructions:\n#{instructions}"
    end

    # ── 3. Fingerprint (for cache lookup only, NOT used in lock key) ──────
    fingerprint = compute_fingerprint(resume, instructions, context[:previous_output])

    # ── 4. Cache hit ──────────────────────────────────────────────────────
    if !force_new && cache_enabled
      cached = AiLog.find_by(resume: resume, feature: feature.to_s, fingerprint: fingerprint, status: "success")
      if cached
        log_rejected(user: user, resume: resume, feature: feature.to_s,
                     prompt_version: prompt_version, fingerprint: fingerprint,
                     model: model, reason: "cache_hit",
                     message: "Served from cache — no API call made",
                     request_meta: request_meta, cache_hit: true)
        Rails.logger.info "[AiService] CACHE HIT user=#{user.id} feature=#{feature} log_id=#{cached.id}"
        return cached.response_content
      end
    end

    # ── 5. Concurrency lock ───────────────────────────────────────────────
    # Lock key intentionally does NOT include fingerprint so that:
    # - Two different tabs generating the SAME feature on the SAME resume are blocked
    # - "Improve" (which changes fingerprint) is also blocked while a generation is running
    lock_key = "ai_lock:user:#{user.id}:resume:#{resume.id}:feature:#{feature}"
    acquired = Rails.cache.write(lock_key, Time.current.to_i, unless_exist: true, expires_in: LOCK_TTL)

    unless acquired
      log_rejected(user: user, resume: resume, feature: feature.to_s,
                   prompt_version: prompt_version, fingerprint: fingerprint,
                   model: model, reason: "duplicate_request",
                   message: "Another generation is already in progress for this feature",
                   request_meta: request_meta, provider: provider_name)
      Rails.logger.warn "[AiService] DUPLICATE BLOCKED user=#{user.id} feature=#{feature} resume=#{resume.id}"
      raise DuplicateRequestError,
        "AI generation already in progress for this feature. Please wait for it to complete."
    end

    Rails.logger.info "[AiService] QUEUED user=#{user.id} feature=#{feature} provider=#{provider_name}"

    # ── 6. Generate with absolute wall-clock timeout ──────────────────────
    start_time  = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    retry_count = 0
    response_text = input_tokens = output_tokens = estimated_cost = nil
    last_error    = nil
    prompt        = nil

    begin
      prompt = PromptLibrary.load(feature, prompt_version, context.merge(
        word_limit:   word_limit,
        instructions: instructions.presence || "None"
      ))

      provider_config   = AI_CONFIG.dig("providers", provider_name) || {}
      provider_class    = resolve_provider_class(provider_name)
      provider_instance = provider_class.new(provider_config)

      Rails.logger.info "[AiService] PROCESSING user=#{user.id} feature=#{feature} provider=#{provider_name} model=#{model}"

      # Absolute wall-clock guard — wraps the ENTIRE retry loop.
      # If this fires, Timeout::Error is raised and rescued below as TimeoutError.
      begin
        Timeout.timeout(GENERATION_TIMEOUT) do
          MAX_RETRIES.times do |attempt|
            begin
              result = provider_instance.generate(
                prompt:            prompt,
                model:             model,
                temperature:       temperature,
                max_output_tokens: max_tokens
              )

              response_text  = result[:content]
              input_tokens   = result[:input_tokens]
              output_tokens  = result[:output_tokens]
              estimated_cost = result[:estimated_cost]
              last_error     = nil
              break # success — exit retry loop

            rescue TimeoutError, ProviderUnavailableError => e
              last_error   = e
              retry_count += 1
              Rails.logger.warn "[AiService] RETRY attempt=#{attempt + 1} user=#{user.id} error=#{e.class} msg=#{e.message}"
              # Small fixed delay between retries; don't use multiplier (wastes timeout budget)
              sleep(1) if attempt < MAX_RETRIES - 1

            rescue RateLimitError, AuthenticationError, InvalidRequestError, ConfigurationError, ApiError => e
              last_error = e
              Rails.logger.warn "[AiService] NON_RETRYABLE_ERROR user=#{user.id} error=#{e.class}"
              break # non-retryable — exit immediately

            rescue => e
              last_error   = e
              retry_count += 1
              Rails.logger.warn "[AiService] GENERIC_ERROR attempt=#{attempt + 1} user=#{user.id} error=#{e.class}"
              sleep(1) if attempt < MAX_RETRIES - 1
            end
          end
        end
      rescue Timeout::Error
        raise TimeoutError, "AI generation timed out after #{GENERATION_TIMEOUT} seconds. Please try again."
      end

      raise last_error if last_error
      raise ApiError, "AI request failed: no response received" unless response_text.present?

      elapsed = elapsed_ms(start_time)
      Rails.logger.info "[AiService] PROVIDER_RESPONSE user=#{user.id} feature=#{feature} elapsed=#{elapsed}ms tokens_in=#{input_tokens} tokens_out=#{output_tokens}"

      # ── 7. Commit: deduct credits + persist log in ONE atomic transaction ─
      # Credits are NEVER deducted before this point.
      ActiveRecord::Base.transaction do
        # Re-check credits inside the lock to guard against concurrent spend
        user.with_lock do
          fresh_remaining = user.remaining_credits.to_i
          raise InsufficientCreditsError,
            "Not enough AI credits after lock (race condition). Please try again." \
            if fresh_remaining < credits_required

          user.update!(
            remaining_credits: fresh_remaining - credits_required,
            used_credits:      user.used_credits.to_i + credits_required
          )
        end

        CreditTransaction.create!(
          user:           user,
          feature_name:   feature.to_s,
          credits_used:   credits_required,
          balance_before: user.remaining_credits.to_i + credits_required,
          balance_after:  user.remaining_credits.to_i,
          action:         "ai_generation",
          reference_id:   nil
        )

        AiLog.create!(
          user:             user,
          resume:           resume,
          feature:          feature.to_s,
          prompt_version:   prompt_version,
          fingerprint:      fingerprint,
          credits_used:     credits_required,
          tokens_in:        input_tokens,
          tokens_out:       output_tokens,
          estimated_cost:   estimated_cost,
          model:            model,
          response_time:    elapsed,
          status:           "success",
          request_prompt:   prompt,
          response_content: response_text,
          cache_hit:        false,
          retry_count:      retry_count,
          ip_address:       request_meta[:ip],
          user_agent:       request_meta[:user_agent],
          request_id:       request_meta[:request_id],
          provider:         provider_name
        )
      end

      Rails.logger.info "[AiService] COMPLETED user=#{user.id} feature=#{feature} credits_deducted=#{credits_required}"
      response_text

    rescue => api_err
      elapsed = elapsed_ms(start_time)
      failure_reason = api_err.is_a?(TimeoutError) ? "timeout" : api_err.class.name
      Rails.logger.error "[AiService] FAILED user=#{user.id} feature=#{feature} error=#{api_err.class} msg=#{api_err.message}"

      log_failed(
        user:           user,
        resume:         resume,
        feature:        feature.to_s,
        prompt_version: prompt_version,
        fingerprint:    fingerprint,
        model:          model,
        response_time:  elapsed,
        error_message:  api_err.message,
        request_prompt: prompt,
        retry_count:    retry_count,
        failure_reason: failure_reason,
        request_meta:   request_meta,
        provider:       provider_name
      )
      raise

    ensure
      # ALWAYS release the lock — even on timeout, exception, or DB rollback.
      # This is the critical cleanup step that prevents users being permanently stuck.
      if acquired
        Rails.cache.delete(lock_key)
        Rails.logger.info "[AiService] LOCK_RELEASED user=#{user.id} feature=#{feature}"
      end
    end
  end

  # ─── Request size validation ─────────────────────────────────────────────
  def self.validate_request_size!(instructions, resume_text)
    if instructions.to_s.split.size > MAX_INSTRUCTIONS_WORDS
      raise RequestTooLargeError,
        "Instructions are too long (max #{MAX_INSTRUCTIONS_WORDS} words). " \
        "Please shorten your instructions."
    end

    if resume_text.to_s.length > MAX_RESUME_TEXT_CHARS
      raise RequestTooLargeError,
        "Resume content exceeds the maximum allowed size. " \
        "Please shorten your resume or remove unused sections."
    end

    combined_length = instructions.to_s.length + resume_text.to_s.length
    if combined_length > (MAX_RESUME_TEXT_CHARS + MAX_INSTRUCTIONS_CHARS)
      raise RequestTooLargeError, "Total request size is too large. Please shorten your content."
    end
  end

  # ─── Helpers ─────────────────────────────────────────────────────────────
  def self.compute_fingerprint(resume, instructions, previous_output = nil)
    Digest::SHA256.hexdigest({
      resume_id:       resume.id,
      content:         resume.content,
      instructions:    instructions.to_s,
      previous_output: previous_output.to_s
    }.to_json)
  end

  def self.sanitize_instructions(raw)
    return "" if raw.blank?
    raw.to_s
       .strip
       .gsub(/[^\w\s.,;:!?()\-'\"\/\n]/u, "")
       .gsub(/\n{3,}/, "\n\n")
       .gsub(/[ \t]{2,}/, " ")
       .first(MAX_INSTRUCTIONS_CHARS)
  end

  def self.elapsed_ms(start_time)
    ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i
  end

  def self.resolve_provider_class(provider_name)
    case provider_name
    when "gemini"     then Ai::Providers::GeminiProvider
    when "groq"       then Ai::Providers::GroqProvider
    when "openrouter" then Ai::Providers::OpenrouterProvider
    else                   Ai::Providers::StubProvider
    end
  end

  # ─── Audit logging ───────────────────────────────────────────────────────
  def self.log_rejected(user:, resume:, feature:, prompt_version:, fingerprint:, model:, reason:, message:, request_meta: {}, cache_hit: false, provider: nil)
    AiLog.create!(
      user:            user,
      resume:          resume,
      feature:         feature,
      prompt_version:  prompt_version,
      fingerprint:     fingerprint,
      credits_used:    0,
      tokens_in:       0,
      tokens_out:      0,
      estimated_cost:  0.0,
      model:           model,
      response_time:   0,
      status:          cache_hit ? "success" : "rejected",
      error_message:   message,
      request_prompt:  nil,
      cache_hit:       cache_hit,
      retry_count:     0,
      failure_reason:  cache_hit ? nil : reason,
      ip_address:      request_meta[:ip],
      user_agent:      request_meta[:user_agent],
      request_id:      request_meta[:request_id],
      provider:        provider
    )
  rescue => e
    Rails.logger.error "[AiService] Failed to write rejected log: #{e.message}"
  end

  def self.log_failed(user:, resume:, feature:, prompt_version:, fingerprint:, model:,
                      response_time:, error_message:, request_prompt:, retry_count: 0, failure_reason: nil, request_meta: {}, provider: nil)
    AiLog.create!(
      user:            user,
      resume:          resume,
      feature:         feature,
      prompt_version:  prompt_version,
      fingerprint:     fingerprint,
      credits_used:    0,
      tokens_in:       0,
      tokens_out:      0,
      estimated_cost:  0.0,
      model:           model,
      response_time:   response_time,
      status:          "failed",
      error_message:   error_message,
      request_prompt:  request_prompt,
      cache_hit:       false,
      retry_count:     retry_count,
      failure_reason:  failure_reason,
      ip_address:      request_meta[:ip],
      user_agent:      request_meta[:user_agent],
      request_id:      request_meta[:request_id],
      provider:        provider
    )
  rescue => e
    Rails.logger.error "[AiService] Failed to write error log: #{e.message}"
  end
end
