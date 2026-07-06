module Api
  module V1
    class ResumeOptimizationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_resume

      def create
        action = params[:optimization_action]
        payload = params.permit(:instructions, :target_role, :job_description).to_h.symbolize_keys

        request_meta = {
          ip: request.remote_ip,
          user_agent: request.user_agent,
          request_id: request.request_id
        }

        result = AiOptimizationService.optimize(@resume, action, payload, request_meta)

        render json: result
      rescue AiService::InsufficientCreditsError => e
        render json: { error: e.message, code: 'insufficient_credits' }, status: :payment_required
      rescue AiOptimizationService::OptimizationError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue => e
        Rails.logger.error "ResumeOptimizationsController Error: #{e.message}"
        render json: { error: 'Internal Server Error' }, status: :internal_server_error
      end

      private

      def set_resume
        @resume = current_user.resumes.find(params[:id])
      end
    end
  end
end
