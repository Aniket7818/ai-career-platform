require_relative "boot"
require_relative "env_loader"

EnvLoader.load!(File.expand_path("..", __dir__))

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AiCareerPlatform
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies

    # Dynamic session cookie config for cross-origin auth (Vercel frontend → Render backend)
    # In production, set COOKIE_SAME_SITE=none and COOKIE_SECURE=true in Render env vars.
    # For local dev, default is same_site=lax, secure=false.
    cookie_same_site = ENV.fetch("COOKIE_SAME_SITE", "lax").to_sym
    cookie_secure = ENV.fetch("COOKIE_SECURE", "false") == "true"
    config.middleware.use ActionDispatch::Session::CookieStore,
      key: "_ai_career_platform_session",
      same_site: cookie_same_site,
      secure: cookie_secure,
      expire_after: 7.days
  end
end
