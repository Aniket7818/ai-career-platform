# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Dynamic CORS origin from FRONTEND_URL env var (set on Render).
# Falls back to localhost:5173 for development.
frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:5173")

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      "http://localhost:5173",
      "http://127.0.0.1:5173",
      frontend_url
    )

    resource "*",
             headers: :any,
             credentials: true,
             methods: %i[get post put patch delete options head]
  end
end
