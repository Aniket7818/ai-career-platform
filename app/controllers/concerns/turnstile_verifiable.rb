require "net/http"
require "json"

module TurnstileVerifiable
  extend ActiveSupport::Concern

  private

  # Verifies a Cloudflare Turnstile token sent from the frontend.
  #
  # Returns true when:
  #   • Rails.env.test?  (never block automated tests)
  #   • TURNSTILE_SECRET_KEY is not set (allows local dev without a key)
  #   • Cloudflare confirms the token is valid
  #
  # Returns false when Cloudflare rejects the token.
  def valid_turnstile?(token)
    return true if Rails.env.test?

    secret = ENV["TURNSTILE_SECRET_KEY"]
    return true if secret.blank?   # graceful degradation in dev/staging without key

    return false if token.blank?

    uri  = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    body = URI.encode_www_form(secret: secret, response: token, remoteip: request.ip)

    begin
      response = Net::HTTP.post(uri, body)
      data     = JSON.parse(response.body)
      data["success"] == true
    rescue StandardError => e
      Rails.logger.warn("[Turnstile] Verification failed: #{e.message}")
      # Fail open to avoid locking out users on network hiccup.
      # Change to `false` if you prefer strict fail-closed behaviour.
      true
    end
  end

  # Controller helper — renders 422 and halts if CAPTCHA is invalid.
  def verify_turnstile!
    token = params[:turnstile_token] || request.headers["X-Turnstile-Token"]
    unless valid_turnstile?(token)
      render json: { error: "CAPTCHA verification failed. Please refresh and try again." },
             status: :unprocessable_entity
    end
  end
end
