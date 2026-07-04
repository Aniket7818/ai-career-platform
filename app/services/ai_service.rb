require 'net/http'
require 'json'
require 'digest'

# AiService – Central AI gateway for CareerAI.
# ALL AI requests must go through this service.
# No controller or feature may call Gemini directly.
class AiService
  class InsufficientCreditsError < StandardError; end
  class ConfigurationError < StandardError; end
  class InvalidInputError < StandardError; end
  class ApiError < StandardError; end

  CONFIG = YAML.load_file(Rails.root.join('config', 'ai_features.yml'))

  # ───────────────────────────────────────────────────────────────────────────
  # Primary entrypoint
  # ───────────────────────────────────────────────────────────────────────────
  def self.generate(user:, resume:, feature:, context: {}, instructions: "", force_new: false)
    feature_config = CONFIG.dig('features', feature.to_s)
    raise ConfigurationError, "Unknown AI feature: #{feature}" unless feature_config

    credits_required = feature_config['credits'].to_i
    word_limit       = feature_config['word_limit'].to_i
    prompt_version   = feature_config['prompt_version']
    cache_enabled    = feature_config['cache_enabled']
    model            = CONFIG.dig('default', 'model')
    temperature      = CONFIG.dig('default', 'temperature')
    max_tokens       = CONFIG.dig('default', 'max_output_tokens')

    # ── 1. Sanitize instructions (not the full context – never validate JSON blobs by word count) ──
    instructions = sanitize_instructions(instructions)

    # ── 2. Validate instructions word limit (max 200 words) ──
    instr_words = instructions.split.size
    raise InvalidInputError, "Instructions exceed 200 words (got #{instr_words})" if instr_words > 200

    # ── 3. Fingerprint: deterministic hash of resume content + instructions ──
    fingerprint = compute_fingerprint(resume, instructions)

    # ── 4. Cache lookup (only for deterministic features) ──
    if !force_new && cache_enabled
      cached = AiLog.find_by(resume: resume, feature: feature.to_s, fingerprint: fingerprint, status: 'success')
      return cached.response_content if cached
    end

    # ── 5. Guard against nil credits (defensive – new users should have defaults) ──
    remaining = user.remaining_credits.to_i
    raise InsufficientCreditsError, "Not enough AI credits. You need #{credits_required} credit(s) but have #{remaining}." if remaining < credits_required

    # ── 6. Load and render prompt from library ──
    prompt = PromptLibrary.load(feature, prompt_version, context.merge(
      word_limit: word_limit,
      instructions: instructions.presence || "None"
    ))

    # ── 7. Call API or stub, track timing ──
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    retry_count = 0

    begin
      response_text, input_tokens, output_tokens, retry_count = call_gemini_api(
        prompt, model, temperature, max_tokens
      )
    rescue ApiError => api_err
      elapsed = elapsed_ms(start_time)
      # Log failure WITHOUT deducting credits
      log_failed(user: user, resume: resume, feature: feature.to_s, prompt_version: prompt_version,
                 fingerprint: fingerprint, model: model, response_time: elapsed,
                 error_message: api_err.message, request_prompt: prompt,
                 retry_count: retry_count, failure_reason: api_err.class.name)
      raise # re-raise for controller to handle
    end

    elapsed = elapsed_ms(start_time)
    estimated_cost = compute_cost(input_tokens, output_tokens)

    # ── 8. Deduct credits ONLY after successful Gemini response ──
    ActiveRecord::Base.transaction do
      user.with_lock do
        user.update!(
          remaining_credits: user.remaining_credits.to_i - credits_required,
          used_credits: user.used_credits.to_i + credits_required
        )
      end

      # Log credit transaction using actual column schema
      CreditTransaction.create!(
        user: user,
        feature_name: feature.to_s,
        credits_used: credits_required,
        balance_before: user.remaining_credits.to_i + credits_required, # before deduction
        balance_after: user.remaining_credits.to_i,
        action: 'ai_generation',
        reference_id: nil
      )

      AiLog.create!(
        user: user,
        resume: resume,
        feature: feature.to_s,
        prompt_version: prompt_version,
        fingerprint: fingerprint,
        credits_used: credits_required,
        tokens_in: input_tokens,
        tokens_out: output_tokens,
        estimated_cost: estimated_cost,
        model: model,
        response_time: elapsed,
        status: 'success',
        request_prompt: prompt,
        response_content: response_text,
        cache_hit: false,
        retry_count: retry_count
      )
    end

    response_text
  end

  # ───────────────────────────────────────────────────────────────────────────
  # Gemini API call with retry logic and timeout
  # ───────────────────────────────────────────────────────────────────────────
  def self.call_gemini_api(prompt, model, temperature, max_tokens)
    api_key = ENV['GEMINI_API_KEY'].presence

    # ── STUB MODE: no API key in development ──
    if api_key.blank?
      if Rails.env.development?
        Rails.logger.warn "[AiService] GEMINI_API_KEY not set – returning stub response"
        stub = "[STUB] This is a simulated AI response for development. " \
               "Add GEMINI_API_KEY to .env to enable real AI generation."
        return [stub, 50, 30, 0]
      else
        raise ConfigurationError, "GEMINI_API_KEY is not configured. Please add it to your environment variables."
      end
    end

    url  = URI("https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{api_key}")
    body = {
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: temperature, maxOutputTokens: max_tokens }
    }

    http              = Net::HTTP.new(url.host, url.port)
    http.use_ssl      = true
    http.read_timeout = 30
    http.open_timeout = 10

    max_retries  = 3
    retry_count  = 0
    last_error   = nil

    max_retries.times do |attempt|
      begin
        request               = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request.body          = body.to_json

        response = http.request(request)
        result   = JSON.parse(response.body)

        unless response.code == '200'
          msg = result.dig('error', 'message') || "Gemini API error (HTTP #{response.code})"
          raise ApiError, msg
        end

        response_text = result.dig('candidates', 0, 'content', 'parts', 0, 'text').to_s
        raise ApiError, "Empty response from Gemini API" if response_text.blank?

        # Approximate token counts (Gemini Flash usage metadata when available)
        input_tokens  = result.dig('usageMetadata', 'promptTokenCount') || (prompt.split.size * 1.3).to_i
        output_tokens = result.dig('usageMetadata', 'candidatesTokenCount') || (response_text.split.size * 1.3).to_i

        return [response_text, input_tokens, output_tokens, retry_count]

      rescue Net::ReadTimeout, Net::OpenTimeout => e
        last_error   = ApiError.new("Request timed out after #{http.read_timeout}s")
        retry_count += 1
        sleep(0.5 * attempt) if attempt < max_retries - 1

      rescue ApiError => e
        last_error   = e
        retry_count += 1
        sleep(0.5 * attempt) if attempt < max_retries - 1

      rescue JSON::ParserError => e
        last_error   = ApiError.new("Invalid response from Gemini API: #{e.message}")
        retry_count += 1
      end
    end

    raise last_error || ApiError.new("AI request failed after #{max_retries} attempts")
  end

  # ───────────────────────────────────────────────────────────────────────────
  # Helpers
  # ───────────────────────────────────────────────────────────────────────────
  def self.compute_fingerprint(resume, instructions)
    Digest::SHA256.hexdigest({
      resume_id:   resume.id,
      content:     resume.content,
      instructions: instructions.to_s
    }.to_json)
  end

  def self.sanitize_instructions(raw)
    return "" if raw.blank?
    raw.to_s
       .strip
       .gsub(/[^\w\s.,;:!?()\-'\"\/\n]/u, '') # strip injection-prone special chars
       .gsub(/\n{3,}/, "\n\n")                  # normalize blank lines
       .gsub(/[ \t]{2,}/, " ")                  # normalize whitespace
       .first(2000)                              # hard cap at 2000 chars
  end

  def self.compute_cost(input_tokens, output_tokens)
    # Gemini 1.5 Flash pricing: $0.075/1M input, $0.30/1M output
    ((input_tokens.to_f / 1_000_000) * 0.075) + ((output_tokens.to_f / 1_000_000) * 0.3)
  end

  def self.elapsed_ms(start_time)
    ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i
  end

  def self.log_failed(user:, resume:, feature:, prompt_version:, fingerprint:, model:,
                       response_time:, error_message:, request_prompt:, retry_count: 0, failure_reason: nil)
    AiLog.create!(
      user: user, resume: resume, feature: feature,
      prompt_version: prompt_version, fingerprint: fingerprint,
      credits_used: 0, tokens_in: 0, tokens_out: 0, estimated_cost: 0.0,
      model: model, response_time: response_time,
      status: 'failed', error_message: error_message,
      request_prompt: request_prompt,
      cache_hit: false, retry_count: retry_count,
      failure_reason: failure_reason
    )
  rescue => e
    Rails.logger.error "[AiService] Failed to write error log: #{e.message}"
  end
end
