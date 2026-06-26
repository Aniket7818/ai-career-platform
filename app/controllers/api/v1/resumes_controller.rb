module Api
  module V1
    class ResumesController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_resume, only: %i[show update destroy download download_pdf]

      def index
        resumes = current_user.resumes.order(updated_at: :desc)
        render json: { resumes: resumes.map { |resume| ResumeSerializer.new(resume).as_json } }
      end

      def show
        render json: { resume: ResumeSerializer.new(@resume).as_json }
      end

      def create
        resume = current_user.resumes.new(resume_params)

        if resume.save
          render json: { resume: ResumeSerializer.new(resume).as_json }, status: :created
        else
          render json: { errors: resume.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @resume.update(resume_params)
          render json: { resume: ResumeSerializer.new(@resume).as_json }
        else
          render json: { errors: @resume.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @resume.destroy
        head :no_content
      end

      def download
        unless current_user.paid_plan? || current_user.free_downloads_remaining.positive?
          return render json: {
            error: "Your free plan supports only 3 PDF downloads. Upgrade your plan to download more resumes.",
            upgrade_required: true
          }, status: :payment_required
        end

        Resume.transaction do
          @resume.increment!(:download_count)
          @resume.update!(downloaded_at: Time.current)
          current_user.increment!(:resume_downloads_count)
        end

        render json: {
          resume: ResumeSerializer.new(@resume.reload).as_json,
          user: UserSerializer.new(current_user.reload).as_json
        }
      end

      def download_pdf
        # Ensure the user has the right to download
        unless current_user.paid_plan? || current_user.free_downloads_remaining.positive?
          return render json: {
            error: "Your free plan supports only 3 PDF downloads. Upgrade your plan to download more resumes.",
            upgrade_required: true
          }, status: :payment_required
        end

        # We pass the user's raw Cookie header to Ferrum so the headless browser is authenticated
        service = ResumePdfService.new(@resume.id, request.headers['Cookie'])
        pdf_data = service.generate_pdf

        # Update download counts
        Resume.transaction do
          @resume.increment!(:download_count)
          @resume.update!(downloaded_at: Time.current)
          current_user.increment!(:resume_downloads_count)
        end

        send_data pdf_data, filename: "resume_#{@resume.id}.pdf", type: 'application/pdf', disposition: 'attachment'
      rescue StandardError => e
        render json: { error: "Failed to generate PDF: #{e.message}" }, status: :internal_server_error
      end

      private

      def set_resume
        @resume = current_user.resumes.find(params[:id])
      end

      def resume_params
        params.require(:resume).permit(:title, :status, :template_id, content: {})
      end
    end
  end
end
