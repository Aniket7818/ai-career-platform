require 'net/http'
require 'uri'
require 'json'

class ResendService
  def self.send_verification_email(user)
    api_key = ENV["RESEND_API_KEY"]
    from = ENV["MAIL_FROM"] || "noreply@aicareerplatform.online"
    frontend_url = ENV["FRONTEND_URL"] || "https://aicareerplatform.online"
    
    return false unless api_key.present?
    
    uri = URI.parse("https://api.resend.com/emails")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    
    confirmation_url = "#{frontend_url}/verify-email?confirmation_token=#{user.confirmation_token}"
    
    html = <<-HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #4F46E5;">Welcome to CareerAI, #{user.first_name}!</h2>
        <p>Thank you for signing up. To complete your registration and unlock all features, please verify your email address.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="#{confirmation_url}" style="background-color: #4F46E5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; font-weight: bold; display: inline-block;">Verify Email</a>
        </div>
        <p>Or copy and paste this link into your browser:</p>
        <p><a href="#{confirmation_url}" style="color: #4F46E5; word-break: break-all;">#{confirmation_url}</a></p>
        <p>This link will expire in 5 minutes.</p>
        <p>Best regards,<br>The CareerAI Team</p>
      </div>
    HTML
    
    request.body = JSON.dump({
      "from" => from,
      "to" => [user.email],
      "subject" => "Verify your CareerAI account",
      "html" => html
    })
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    response.is_a?(Net::HTTPSuccess)
  end

  def self.send_password_reset_email(user, token)
    api_key = ENV["RESEND_API_KEY"]
    from = ENV["MAIL_FROM"] || "noreply@aicareerplatform.online"
    frontend_url = ENV["FRONTEND_URL"] || "https://aicareerplatform.online"
    
    return false unless api_key.present?
    
    uri = URI.parse("https://api.resend.com/emails")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    
    reset_url = "#{frontend_url}/reset-password?token=#{token}"
    
    html = <<-HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #4F46E5;">Reset Your CareerAI Password</h2>
        <p>We received a request to reset your password. Click the button below to choose a new password:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="#{reset_url}" style="background-color: #4F46E5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; font-weight: bold; display: inline-block;">Reset Password</a>
        </div>
        <p>Or copy and paste this link into your browser:</p>
        <p><a href="#{reset_url}" style="color: #4F46E5; word-break: break-all;">#{reset_url}</a></p>
        <p>This link expires in 24 hours.</p>
        <p>If you did not request this reset, ignore this email.</p>
        <p>Best regards,<br>The CareerAI Team</p>
      </div>
    HTML
    
    request.body = JSON.dump({
      "from" => from,
      "to" => [user.email],
      "subject" => "Reset Your CareerAI Password",
      "html" => html
    })
    
    req_options = { use_ssl: uri.scheme == "https" }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    response.is_a?(Net::HTTPSuccess)
  end
end
