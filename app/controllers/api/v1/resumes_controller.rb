module Api
  module V1
    class ResumesController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_resume, only: %i[show update destroy download download_pdf score analyze]
      before_action :ensure_versioning_initialized, only: %i[show update score analyze]

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
          # Phase 3.1: Create the initial "Original" version snapshot
          ResumeVersionService.create_initial(resume)
          render json: { resume: ResumeSerializer.new(resume).as_json }, status: :created
        else
          render json: { errors: resume.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @resume.update(resume_params)
          # Phase 3.1: Create a snapshot on explicit user saves (not autosave spam).
          # NothingChangedError is silently swallowed — it's not an error, just a skip.
          begin
            next_num = @resume.latest_version_number + 1
            ResumeVersionService.snapshot(
              @resume,
              label:          "Version #{next_num}",
              source:         "manual",
              change_summary: nil
            )
          rescue ResumeVersionService::NothingChangedError
            # Content hasn't changed — skip snapshot silently
          end
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
        service = ResumePdfService.new(@resume.id, request.headers["Cookie"])
        pdf_data = service.generate_pdf

        # Update download counts
        Resume.transaction do
          @resume.increment!(:download_count)
          @resume.update!(downloaded_at: Time.current)
          current_user.increment!(:resume_downloads_count)
        end

        send_data pdf_data, filename: "resume_#{@resume.id}.pdf", type: "application/pdf", disposition: "attachment"
      rescue StandardError => e
        render json: { error: "Failed to generate PDF: #{e.message}" }, status: :internal_server_error
      end

      # GET /api/v1/resumes/:id/score
      def score
        render json: {
          success: true,
          overall_score: @resume.last_analysis_score,
          ats_score: @resume.ats_score,
          keyword_score: @resume.keyword_score,
          content_score: @resume.content_score,
          completeness_score: @resume.completeness_score,
          last_analyzed_at: @resume.last_analyzed_at,
          analysis_data: @resume.analysis_data || {}
        }
      end

      # POST /api/v1/resumes/:id/score
      def analyze
        analysis = ResumeScoreService.analyze(@resume)
        
        render json: {
          success: true,
          overall_score: @resume.last_analysis_score,
          ats_score: @resume.ats_score,
          keyword_score: @resume.keyword_score,
          content_score: @resume.content_score,
          completeness_score: @resume.completeness_score,
          last_analyzed_at: @resume.last_analyzed_at,
          analysis_data: analysis
        }
      rescue => e
        Rails.logger.error "[ResumesController#analyze] Error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
        render json: { success: false, error: "Failed to analyze resume." }, status: :internal_server_error
      end

      private

      def set_resume
        @resume = current_user.resumes.find(params[:id])
      end

      # Phase 3.1: Ensure every existing resume (created before versioning was
      # introduced) has at least an "Original" version on record. Called lazily
      # on show and update so legacy resumes are quietly backfilled.
      def ensure_versioning_initialized
        return unless @resume
        ResumeVersionService.create_initial(@resume) unless @resume.resume_versions.exists?
      end

      def resume_params
        params.require(:resume).permit(:title, :status, :template_id, :target_role, content: {})
      end
    end
  end
end
