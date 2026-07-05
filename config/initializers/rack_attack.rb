# rack-attack configuration.
# Registration into the middleware stack is handled automatically by
# the gem's built-in Railtie — no manual insert needed here.

class Rack::Attack
  # ── Safelist ────────────────────────────────────────────────────────────────
  # Health-check is always exempt.
  safelist("allow-health-check") { |req| req.path == "/up" }

  # Localhost is exempt in development UNLESS you set RACK_ATTACK_DEV_TEST=true
  # in your .env to verify throttling locally (flip it back off when done).
  safelist("allow-localhost") do |req|
    is_localhost = [ "127.0.0.1", "::1" ].include?(req.ip)
    dev_test_mode = ENV["RACK_ATTACK_DEV_TEST"] == "true"
    is_localhost && !Rails.env.production? && !dev_test_mode
  end

  # ── Helpers ─────────────────────────────────────────────────────────────────
  # Render load balancers can change IPs, which breaks standard req.ip if not
  # trusted. We use ActionDispatch to reliably get the real client IP.
  def self.client_ip(req)
    # The first IP in X-Forwarded-For is the true client IP in most setups.
    forwarded = req.env["HTTP_X_FORWARDED_FOR"]
    return forwarded.split(",").first.strip if forwarded.present?

    req.ip
  end

  # ════════════════════════════════════════════════════════════════════════════
  # PASSWORD RESET  — POST /api/v1/auth/forgot_password
  #   • 5 requests per IP per 60 s  (catches rapid-fire bot loops)
  #   • 20 requests per IP per 1 h  (catches slow enumeration)
  # ════════════════════════════════════════════════════════════════════════════
  throttle("forgot_password/ip/burst", limit: 5, period: 60.seconds) do |req|
    client_ip(req) if req.path == "/api/v1/auth/forgot_password" && req.post?
  end

  throttle("forgot_password/ip/hourly", limit: 20, period: 1.hour) do |req|
    client_ip(req) if req.path == "/api/v1/auth/forgot_password" && req.post?
  end

  # ════════════════════════════════════════════════════════════════════════════
  # LOGIN  — POST /api/v1/auth/login
  #   • 10 attempts per IP per 60 s
  #   • 50 attempts per IP per 10 min  (slow-drip brute force)
  # ════════════════════════════════════════════════════════════════════════════
  throttle("login/ip/burst", limit: 10, period: 60.seconds) do |req|
    client_ip(req) if req.path == "/api/v1/auth/login" && req.post?
  end

  throttle("login/ip/slow", limit: 50, period: 10.minutes) do |req|
    client_ip(req) if req.path == "/api/v1/auth/login" && req.post?
  end

  # ════════════════════════════════════════════════════════════════════════════
  # SIGNUP  — POST /api/v1/auth/signup
  #   • 5 signups per IP per 10 min  (stops mass account creation)
  # ════════════════════════════════════════════════════════════════════════════
  throttle("signup/ip", limit: 5, period: 10.minutes) do |req|
    client_ip(req) if req.path == "/api/v1/auth/signup" && req.post?
  end

  # ════════════════════════════════════════════════════════════════════════════
  # EMAIL VERIFICATION  — POST /api/v1/verifications
  #   • 5 requests per IP per 5 min  (already has per-user DB limit too)
  # ════════════════════════════════════════════════════════════════════════════
  throttle("verification/ip", limit: 5, period: 5.minutes) do |req|
    client_ip(req) if req.path == "/api/v1/verifications" && req.post?
  end

  # ════════════════════════════════════════════════════════════════════════════
  # AI ENDPOINTS
  #
  #   Generate (Expensive) — POST /api/v1/ai/generate
  #     • Burst: 3 requests per 10s per user
  #     • Sustained: 5 requests per 60s per user
  #     • IP ceiling: 20 requests per 60s
  #
  #   Read/Restore (Cheap) — GET /api/v1/ai/history, GET /versions, POST /restore
  #     • History/Preview: 60 requests per 60s per user
  #     • Restore: 20 requests per 60s per user
  # ════════════════════════════════════════════════════════════════════════════
  # Helper: cheaply extract user_id from Warden without full controller stack.
  def self.ai_user_key(req)
    uid = req.env.dig("warden", :user, :id) ||
          req.session&.dig("warden.user.user.key", 0, 0) rescue nil
    uid ? "user:#{uid}" : "ip:#{client_ip(req)}"
  end

  # -- Generate --
  throttle("ai/generate/user/burst", limit: 3, period: 10.seconds) do |req|
    Rack::Attack.ai_user_key(req) if req.path == "/api/v1/ai/generate" && req.post?
  end

  throttle("ai/generate/user/minute", limit: 5, period: 60.seconds) do |req|
    Rack::Attack.ai_user_key(req) if req.path == "/api/v1/ai/generate" && req.post?
  end

  throttle("ai/generate/ip/minute", limit: 20, period: 60.seconds) do |req|
    client_ip(req) if req.path == "/api/v1/ai/generate" && req.post?
  end

  # -- History & Preview --
  throttle("ai/history/user/minute", limit: 60, period: 60.seconds) do |req|
    Rack::Attack.ai_user_key(req) if (req.path == "/api/v1/ai/history" || req.path == "/api/v1/ai/versions") && req.get?
  end

  # -- Restore --
  throttle("ai/restore/user/minute", limit: 20, period: 60.seconds) do |req|
    Rack::Attack.ai_user_key(req) if req.path.match?(%r{^/api/v1/ai/versions/\d+/restore$}) && req.post?
  end

  # ════════════════════════════════════════════════════════════════════════════
  # GENERAL API  — catch any endpoint not covered above
  #   • 300 requests per IP per 5 min
  # ════════════════════════════════════════════════════════════════════════════
  throttle("api/ip/general", limit: 300, period: 5.minutes) do |req|
    client_ip(req) if req.path.start_with?("/api/")
  end

  # ── Throttled response: always return JSON, never HTML ───────────────────────
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    now = match_data[:epoch_time] || Time.now.to_i

    retry_after = match_data[:period] ? (match_data[:period] - (now % match_data[:period])).to_s : "60"
    [
      429,
      {
        "Content-Type"  => "application/json",
        "Retry-After"   => retry_after
      },
      [ '{"error":"Too many requests. Please slow down and try again later.","retry_after":' + retry_after + "}" ]
    ]
  end

  # ── Blocklisted response (for future use) ────────────────────────────────────
  self.blocklisted_responder = lambda do |request|
    [ 403, { "Content-Type" => "application/json" }, [ '{"error":"Forbidden."}' ] ]
  end
end
