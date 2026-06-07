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
            sign_out(resource_name)
            return render json: { error: "Your account has been suspended. Please contact support." }, status: :forbidden
          end

          resource.update(last_login_at: Time.current, verified_at: resource.verified_at || Time.current)
          resource.login_sessions.create!(
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            session_id: request.session_options[:id],
            logged_in_at: Time.current
          )
          sign_in(resource_name, resource)
          render json: { user: UserSerializer.new(resource).as_json }, status: :ok
        end

        def destroy
          sign_out(resource_name)
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
