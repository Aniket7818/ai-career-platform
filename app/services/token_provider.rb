class TokenProvider
  def self.encode(payload, expires_in = 7.days)
    verifier = Rails.application.message_verifier("auth_token")
    verifier.generate(payload, expires_in: expires_in)
  end

  def self.decode(token)
    return nil if token.blank?
    verifier = Rails.application.message_verifier("auth_token")
    verifier.verified(token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
