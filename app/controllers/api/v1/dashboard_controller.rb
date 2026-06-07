module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_api_user!

      def show
        resumes = current_user.resumes.order(updated_at: :desc)
        render json: {
          user: UserSerializer.new(current_user).as_json,
          stats: {
            total_resumes: resumes.count,
            draft_resumes: resumes.where(status: ResumeStatus::DRAFT).count,
            published_resumes: resumes.where(status: ResumeStatus::PUBLISHED).count,
            profile_strength: profile_strength
          },
          recent_resumes: resumes.limit(5).map { |resume| ResumeSerializer.new(resume).as_json }
        }
      end

      private

      def profile_strength
        fields = %i[first_name last_name title location phone website linkedin github bio avatar]
        completed = fields.count { |field| current_user.public_send(field).present? }
        ((completed.to_f / fields.length) * 100).round
      end
    end
  end
end
