class ApplicationController < ActionController::API
  include ActionController::Cookies
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :render_duplicate_error

  private

  def authenticate_api_user!
    return if user_signed_in?

    render json: { error: I18n.t("api.errors.unauthorized") }, status: :unauthorized
  end

  def require_admin!
    return if current_user&.role.in?(%w[admin super_admin])

    render json: { error: "Admin access is required." }, status: :forbidden
  end

  def authorize_feature!(feature_key)
    unless user_signed_in?
      return render json: { error: I18n.t("api.errors.unauthorized") }, status: :unauthorized
    end

    # Bypass for admin / super_admin
    return if current_user.role.in?(%w[admin super_admin])

    plan = current_user.subscription_plan || "free"
    is_paid = current_user.paid_plan?
    active_plan = is_paid ? plan : "free"

    allowed = case feature_key.to_s.underscore.to_sym
    when :ats, :can_use_ats, :ai_ats_checker
                active_plan.in?(%w[plus pro team])
    when :resume_coach, :can_use_resume_coach, :ai_resume_assistant
                active_plan.in?(%w[plus pro team])
    when :keywords, :can_use_keywords
                active_plan.in?(%w[plus pro team])
    when :resume_rewrite, :can_use_resume_rewrite
                active_plan.in?(%w[plus pro team])
    when :cover_letter, :can_use_cover_letter, :ai_cover_letter
                active_plan.in?(%w[plus pro team])
    when :linkedin_review, :can_use_linkedin_review, :linkedin_review
                active_plan.in?(%w[plus pro team])
    when :interview_prep, :can_use_interview_prep, :ai_mock_interviews
                active_plan.in?(%w[pro team])
    when :career_roadmap, :can_use_career_roadmap, :career_roadmap
                active_plan.in?(%w[pro team])
    when :job_match, :can_use_job_match
                active_plan.in?(%w[pro team])
    when :advanced_ats, :can_use_advanced_ats
                active_plan.in?(%w[pro team])
    else
                false
    end

    unless allowed
      render json: { error: "Upgrade required. This feature is not available on your current plan." }, status: :forbidden
    end
  end

  def render_not_found
    render json: { error: I18n.t("api.errors.not_found") }, status: :not_found
  end

  def render_duplicate_error(exception)
    message = if exception.message.include?("email")
                I18n.t("api.errors.email_taken")
    elsif exception.message.include?("username")
                I18n.t("api.errors.username_taken")
    else
                I18n.t("api.errors.duplicate_record")
    end
    render json: { errors: [ message ] }, status: :unprocessable_entity
  end

  def friendly_validation_errors(record)
    record.errors.map do |error|
      case error.attribute.to_sym
      when :email
        error.type == :taken ? I18n.t("api.errors.email_taken") : error.full_message
      when :username
        error.type == :taken ? I18n.t("api.errors.username_taken") : error.full_message
      when :password
        I18n.t("api.errors.password_invalid")
      else
        error.full_message
      end
    end.uniq
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name username title location])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name username title location phone website linkedin github bio])
  end
end
