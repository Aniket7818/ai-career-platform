module Api
  module V1
    class VerificationsController < ApplicationController
      before_action :authenticate_user!, only: [:create]

      # POST /api/v1/verifications
      def create
        if current_user.verified?
          return render json: { error: "Email is already verified." }, status: :unprocessable_entity
        end

        # Check rate limits
        now = Time.current
        logs_last_24h = current_user.email_verification_logs.where("sent_at >= ?", 24.hours.ago).count
        if logs_last_24h >= 7
          return render json: { error: "You can only send 7 verification emails per 24 hours. Please try again tomorrow." }, status: :too_many_requests
        end

        logs_last_hour = current_user.email_verification_logs.where("sent_at >= ?", 1.hour.ago).count
        if logs_last_hour >= 5
          return render json: { error: "You can only send 5 verification emails per hour. Please wait." }, status: :too_many_requests
        end

        last_log = current_user.email_verification_logs.order(sent_at: :desc).first
        if last_log && last_log.sent_at >= 5.minutes.ago
          time_left = (last_log.sent_at + 5.minutes - now).to_i
          return render json: { 
            error: "Verification email has already been sent. Please retry after #{time_left / 60}m #{time_left % 60}s.",
            retry_after: time_left
          }, status: :too_many_requests
        end

        current_user.send(:generate_confirmation_token)
        current_user.confirmation_sent_at = now
        current_user.save!(validate: false)

        if ResendService.send_verification_email(current_user)
          current_user.email_verification_logs.create!(sent_at: now)
          render json: { message: "Verification email sent successfully." }, status: :ok
        else
          render json: { error: "Failed to send verification email. Please try again later." }, status: :internal_server_error
        end
      end

      # POST /api/v1/verifications/verify
      def verify
        token = params[:confirmation_token]
        return render json: { error: "Token is missing" }, status: :bad_request unless token.present?

        user = User.find_by(confirmation_token: token)
        return render json: { error: "Invalid or expired token." }, status: :unprocessable_entity unless user

        # Check if token is older than 5 minutes
        if user.confirmation_sent_at && user.confirmation_sent_at < 5.minutes.ago
          return render json: { error: "Token has expired. Please request a new one." }, status: :unprocessable_entity
        end

        if user.confirm
          user.update_column(:verified_at, Time.current)
          render json: { message: "Email verified successfully." }, status: :ok
        else
          render json: { error: "Could not verify email." }, status: :unprocessable_entity
        end
      end
    end
  end
end
