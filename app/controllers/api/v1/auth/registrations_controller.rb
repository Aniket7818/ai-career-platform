module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        include TurnstileVerifiable
        respond_to :json

        # Verify CAPTCHA on signup to block bot account creation.
        before_action :verify_turnstile!, only: [ :create ]

        def create
          build_resource(sign_up_params)

          if resource.save
            sign_up(resource_name, resource)
            resource.update(last_login_at: Time.current)
            # Force session to load before reading its id
            session[:init] = true
            resource.login_sessions.create!(
              ip_address: request.remote_ip,
              user_agent: request.user_agent,
              session_id: session.id,
              logged_in_at: Time.current
            )
            render json: { 
              user: UserSerializer.new(resource).as_json,
              ai_features: AiService::CONFIG["features"]
            }, status: :created
            sign_out(resource_name)
            render json: { errors: friendly_validation_errors(resource) }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
