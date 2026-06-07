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
    render json: { errors: [message] }, status: :unprocessable_entity
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
