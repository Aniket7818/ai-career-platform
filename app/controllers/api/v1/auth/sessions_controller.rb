module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        def create
          self.resource = User.find_for_database_authentication(login: sign_in_params[:login])

          unless resource&.valid_password?(sign_in_params[:password])
            sign_out(resource_name)
            return render json: { error: I18n.t("api.auth.invalid_credentials") }, status: :unauthorized
          end

          unless resource.active_for_authentication?
            inactive_reason = resource.inactive_message
            sign_out(resource_name)
            error_message = case inactive_reason
            when :suspended then "Your account has been suspended. Please contact support."
            when :unconfirmed then "Please verify your email address before logging in."
            else I18n.t("devise.failure.#{inactive_reason}", default: "Your account is not active.")
            end
            return render json: { error: error_message }, status: :forbidden
          end

          resource.update(last_login_at: Time.current)
          # Force session to load before reading its id
          session[:init] = true
          resource.login_sessions.create!(
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            session_id: session.id,
            logged_in_at: Time.current
          )
          token = TokenProvider.encode({ user_id: resource.id })
          sign_in(resource_name, resource)
          render json: { user: UserSerializer.new(resource).as_json, token: token }, status: :ok
        end

        def destroy
          # Record logout time on the current login session if available
          if user_signed_in?
            current_user.login_sessions.where(logged_out_at: nil).order(logged_in_at: :desc).first&.update!(logged_out_at: Time.current)
          end
          sign_out(resource_name)
          # Explicitly clear the session cookie
          cookies.delete("_ai_career_platform_session", domain: :all)
          render json: { message: I18n.t("api.auth.signed_out") }, status: :ok
        end

        private

        def sign_in_params
          params.require(:user).permit(:login, :password)
        end
      end
    end
  end
end
