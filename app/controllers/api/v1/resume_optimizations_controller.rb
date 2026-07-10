module Api
  module V1
    class ResumeOptimizationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_resume

      def create
        action = params[:optimization_action]
        payload = params.permit(
          :instructions,
          :target_role,
          :job_description,
          :project_id,
          :project_action,
          :project_field,
          :experience_id,
          :bullet_text,
          :company_name,
          :hiring_manager,
          :tone,
          :length,
          :industry
        ).to_h.symbolize_keys

        request_meta = {
          ip: request.remote_ip,
          user_agent: request.user_agent,
          request_id: request.request_id
        }

        result = AiOptimizationService.optimize(@resume, action, payload, request_meta)
        
        log = current_user.ai_logs.order(created_at: :desc).first
        if log
          result[:stats] = {
            credits_used: log.credits_used,
            provider: log.provider || 'Groq',
            input_tokens: log.tokens_in || 0,
            output_tokens: log.tokens_out || 0,
            version: @resume.resume_versions.last&.label || "Draft"
          }
        end

        render json: result
      rescue AiService::RateLimitError => e
        render json: {
          success: false,
          error_code: "AI_RATE_LIMIT",
          title: "AI Service Busy",
          message: "Our AI provider is temporarily unavailable because it has reached its usage limit. Please try again in a few minutes.\n\nNo credits have been deducted.",
          retry_after: 1440
        }, status: :too_many_requests
      rescue AiService::TimeoutError => e
        render json: {
          success: false,
          error_code: "AI_TIMEOUT",
          title: "Request Timed Out",
          message: "AI is taking longer than expected. Please try again.\n\nNo credits have been deducted."
        }, status: :gateway_timeout
      rescue AiService::ProviderUnavailableError => e
        render json: {
          success: false,
          error_code: "AI_PROVIDER_UNAVAILABLE",
          title: "Service Unavailable",
          message: "Our AI provider is temporarily unavailable. Please try again later.\n\nNo credits have been deducted."
        }, status: :service_unavailable
      rescue AiService::InvalidRequestError, AiService::ApiError => e
        render json: {
          success: false,
          error_code: "AI_INVALID_RESPONSE",
          title: "Invalid Response",
          message: "The AI returned an unexpected response. Please try again.\n\nNo credits have been deducted."
        }, status: :bad_gateway
      rescue AiOptimizationService::OptimizationError => e
        render json: {
          success: false,
          error_code: "AI_OPTIMIZATION_ERROR",
          title: "Optimization Failed",
          message: e.message
        }, status: :unprocessable_entity
      rescue AiService::InsufficientCreditsError => e
        render json: { error: e.message, code: 'insufficient_credits' }, status: :payment_required
      rescue => e
        Rails.logger.error "ResumeOptimizationsController Error: #{e.message}"
        render json: {
          success: false,
          error_code: "INTERNAL_ERROR",
          title: "Internal Error",
          message: "Something went wrong while processing your request. Please try again later."
        }, status: :internal_server_error
      end

      private

      def set_resume
        @resume = current_user.resumes.find(params[:id])
      end
    end
  end
end
