module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        include TurnstileVerifiable
        respond_to :json

        # Verify CAPTCHA before attempting password reset to stop bots.
        before_action :verify_turnstile!, only: [ :create ]

        def create
          email = params[:email] || params.dig(:user, :email)
          user = User.find_by(email: email.to_s.downcase)

          if user
            result = handle_user_reset_request(user)
            if result == :limit_exceeded
              return render json: { error: "You have reached the daily password reset limit. Please try again tomorrow." }, status: :too_many_requests
            end
          end

          render json: { message: "If an account exists, a reset email has been sent." }, status: :ok
        end


        def update
          token = params[:token] || params.dig(:user, :reset_password_token)
          password = params[:password] || params.dig(:user, :password)
          password_confirmation = params[:password_confirmation] || params.dig(:user, :password_confirmation)

          self.resource = resource_class.reset_password_by_token(
            reset_password_token: token,
            password: password,
            password_confirmation: password_confirmation
          )

          if resource.errors.empty?
            resource.unlock_access! if unlockable?(resource)
            render json: { message: "Password successfully changed." }, status: :ok
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def validate_token
          original_token = params[:reset_password_token]
          reset_password_token = Devise.token_generator.digest(User, :reset_password_token, original_token)
          user = User.find_by(reset_password_token: reset_password_token)

          if user && user.reset_password_period_valid?
            render json: { valid: true }, status: :ok
          else
            render json: { valid: false, error: "Invalid or expired token." }, status: :unprocessable_entity
          end
        end

        private

        def handle_user_reset_request(user)
          if user.last_reset_request_at.nil? || user.last_reset_request_at < 24.hours.ago
            user.update!(reset_emails_sent_count: 0)
          end

          if user.reset_emails_sent_count >= 2
            return :limit_exceeded
          end

          user.increment!(:reset_emails_sent_count)
          user.update!(last_reset_request_at: Time.current)

          raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
          user.update!(
            reset_password_token: hashed_token,
            reset_password_sent_at: Time.now.utc
          )

          ResendService.send_password_reset_email(user, raw_token)
        end
      end
    end
  end
end
