# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source, env|
      # Base allowed origins
      allowed = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "https://ai-career-platform-tan.vercel.app",
        "https://aicareerplatform.online",
        "https://www.aicareerplatform.online"
      ]

      # Add origins from FRONTEND_URL if set
      if ENV["FRONTEND_URL"].present?
        allowed << ENV["FRONTEND_URL"]
      end

      # Add origins from CORS_ORIGINS if set (comma separated)
      if ENV["CORS_ORIGINS"].present?
        allowed.concat(ENV["CORS_ORIGINS"].split(",").map(&:strip))
      end

      allowed.uniq.include?(source)
    end

    resource "*",
             headers: :any,
             credentials: true,
             methods: %i[get post put patch delete options head]
  end
end
