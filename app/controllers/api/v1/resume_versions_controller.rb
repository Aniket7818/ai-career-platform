module Api
  module V1
    # ResumeVersionsController — manages the version history of a specific resume.
    #
    # All routes are nested under /resumes/:resume_id:
    #   GET    /resumes/:resume_id/versions       → index   (list all versions)
    #   GET    /resumes/:resume_id/versions/:id   → show    (full content snapshot)
    #   POST   /resumes/:resume_id/versions/:id/restore → restore (create restore version)
    #   GET    /resumes/:resume_id/versions/diff  → diff    (compare two versions)
    class ResumeVersionsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_resume
      before_action :set_version, only: %i[show restore]

      # GET /api/v1/resumes/:resume_id/versions
      # Returns the version list (lightweight — no content_snapshot in list view).
      def index
        versions = ResumeVersionService.list(@resume)
        render json: {
          resume_id: @resume.id,
          versions:  versions.map(&:api_json)
        }
      end

      # GET /api/v1/resumes/:resume_id/versions/:id
      # Returns a single version including the full content snapshot.
      # Used when the user wants to preview or compare an older version.
      def show
        render json: {
          version: @version.api_json_with_content
        }
      end

      # POST /api/v1/resumes/:resume_id/versions/:id/restore
      # Creates a new "restore" version from the target version's snapshot.
      # The live resume content is updated to match the restored version.
      # Non-destructive — version history is never modified.
      def restore
        new_version = ResumeVersionService.restore(
          version_id: @version.id,
          user:       current_user
        )

        # Return the updated resume alongside the new version so the frontend
        # can refresh both the editor content and the version list in one call.
        render json: {
          message:     "Version restored successfully.",
          new_version: new_version.api_json,
          resume:      ResumeSerializer.new(@resume.reload).as_json
        }, status: :created

      rescue ResumeVersionService::AccessDeniedError => e
        render json: { error: e.message }, status: :forbidden
      rescue ResumeVersionService::VersionNotFoundError => e
        render json: { error: e.message }, status: :not_found
      end

      # GET /api/v1/resumes/:resume_id/versions/diff?a=VERSION_A_ID&b=VERSION_B_ID
      # Returns a structural diff between two versions.
      # Query params:
      #   a — ID of the "before" (older) version
      #   b — ID of the "after"  (newer) version
      def diff
        version_a = ResumeVersionService.find_with_access_check(params[:a].to_i, current_user)
        version_b = ResumeVersionService.find_with_access_check(params[:b].to_i, current_user)

        # Both versions must belong to the same resume as the URL param
        unless version_a.resume_id == @resume.id && version_b.resume_id == @resume.id
          return render json: { error: "Both versions must belong to the same resume." }, status: :unprocessable_entity
        end

        render json: { diff: ResumeVersionService.diff(version_a, version_b) }

      rescue ResumeVersionService::VersionNotFoundError => e
        render json: { error: e.message }, status: :not_found
      rescue ResumeVersionService::AccessDeniedError => e
        render json: { error: e.message }, status: :forbidden
      end

      private

      def set_resume
        @resume = current_user.resumes.find_by(id: params[:resume_id])
        render json: { error: "Resume not found" }, status: :not_found unless @resume
      end

      def set_version
        @version = @resume.resume_versions.find_by(id: params[:id])
        render json: { error: "Version not found" }, status: :not_found unless @version
      end
    end
  end
end
