module Api
  module V1
    class AiController < ApplicationController
      before_action :authenticate_user!
      before_action :find_resume, only: [:generate, :history, :versions]

      ALLOWED_FEATURES = %w[
        resume_summary
        resume_rewrite
        ats_suggestions
        resume_improvement_tips
        professional_experience_improvement
        project_description_improvement
        skill_suggestions
      ].freeze

      # POST /api/v1/ai/generate
      def generate
        feature      = params[:feature].to_s
        instructions = params[:instructions].to_s
        force_new    = params[:force_new].in?([true, 'true', '1'])

        unless ALLOWED_FEATURES.include?(feature)
          return render json: { success: false, error: "Unknown feature: #{feature}" }, status: :unprocessable_entity
        end

        # Build context: the resume content is the "document" the AI works on
        context = {
          resume_content: build_resume_text(@resume)
        }

        response_text = AiService.generate(
          user:         current_user,
          resume:       @resume,
          feature:      feature,
          context:      context,
          instructions: instructions,
          force_new:    force_new
        )

        # Refresh user credits in response so frontend can update immediately
        current_user.reload
        render json: {
          success:           true,
          response:          response_text,
          remaining_credits: current_user.remaining_credits.to_i
        }

      rescue AiService::ConfigurationError, AiService::InvalidInputError => e
        render json: { success: false, error: e.message }, status: :unprocessable_entity
      rescue AiService::InsufficientCreditsError => e
        render json: { success: false, error: e.message, remaining_credits: current_user.remaining_credits.to_i }, status: :payment_required
      rescue AiService::ApiError => e
        render json: { success: false, error: e.message }, status: :bad_gateway
      rescue => e
        Rails.logger.error "[AiController#generate] #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
        render json: { success: false, error: "An unexpected error occurred. Please try again." }, status: :internal_server_error
      end

      # GET /api/v1/ai/history?resume_id=X&feature=Y
      def history
        feature = params[:feature].to_s
        logs    = AiLog.where(resume: @resume, feature: feature, status: 'success').order(created_at: :desc)
        render json: {
          success: true,
          history: logs.as_json(only: [:id, :created_at, :credits_used, :response_content, :prompt_version])
        }
      end

      # GET /api/v1/ai/versions?resume_id=X&feature=Y
      def versions
        feature = params[:feature].to_s
        logs    = AiLog.where(resume: @resume, feature: feature, status: 'success').order(created_at: :desc)
        render json: {
          success:  true,
          versions: logs.as_json(only: [:id, :created_at, :credits_used, :prompt_version, :response_time])
        }
      end

      # GET /api/v1/ai/versions/:id
      def show_version
        log = AiLog.find_by!(id: params[:id], user: current_user)
        render json: {
          success: true,
          version: log.as_json(only: [:id, :created_at, :response_content, :request_prompt, :feature])
        }
      end

      # POST /api/v1/ai/versions/:id/restore
      # Does NOT consume credits, does NOT call Gemini.
      def restore_version
        log = AiLog.find_by!(id: params[:id], user: current_user)
        render json: {
          success:  true,
          response: log.response_content,
          feature:  log.feature
        }
      end

      private

      def find_resume
        resume_id = params[:resume_id]
        if resume_id.blank?
          render json: { success: false, error: "resume_id is required" }, status: :unprocessable_entity
          return
        end
        @resume = current_user.resumes.find_by(id: resume_id)
        unless @resume
          render json: { success: false, error: "Resume not found or access denied" }, status: :not_found
        end
      end

      # Convert resume content hash to human-readable text for the AI prompt.
      # Avoids sending raw JSON (which inflates word counts and confuses the model).
      def build_resume_text(resume)
        c = resume.content || {}
        lines = []

        p = c['personal'] || {}
        lines << "Name: #{p['fullName']}" if p['fullName'].present?
        lines << "Headline: #{p['headline']}" if p['headline'].present?
        lines << "Summary: #{p['summary']}" if p['summary'].present?

        (c['experiences'] || []).each do |e|
          lines << "Experience: #{e['role']} at #{e['company']} (#{e['startDate']}–#{e['endDate']})"
          lines << e['description'] if e['description'].present?
        end

        (c['educations'] || []).each do |e|
          lines << "Education: #{e['degree']} at #{e['institution']} (#{e['year']})"
        end

        (c['projects'] || []).each do |pr|
          lines << "Project: #{pr['name']} – #{pr['description']}"
        end

        skills = c.dig('skills', 'skillList')
        lines << "Skills: #{skills}" if skills.present?

        (c['certifications'] || []).each do |cert|
          lines << "Certification: #{cert['name']} – #{cert['issuer']}"
        end

        lines.compact.join("\n")
      end
    end
  end
end
