require "csv"

module Api
  module V1
    class AdminController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin!

      def show
        render json: {
          analytics: analytics,
          users: users_payload,
          resume_analytics: resume_analytics,
          feature_interest_analytics: feature_interest_analytics,
          subscription_analytics: subscription_analytics,
          settings: settings_payload,
          audit_logs: audit_logs_payload,
          login_sessions: login_sessions_payload,
          growth: growth_payload
        }
      end

      def update_user
        user = User.find(params[:id])
        return render json: { error: "Admins cannot edit super admin accounts." }, status: :forbidden if current_user.role == "admin" && user.super_admin?

        if user_params[:role].present?
          if user == current_user && user_params[:role] != user.role
            return render json: { error: "You cannot change your own role." }, status: :forbidden
          end
          if current_user.role == "admin" && user_params[:role] != user.role
            return render json: { error: "Admins cannot change user roles." }, status: :forbidden
          end
          if current_user.role == "admin" && user_params[:role] == "super_admin"
            return render json: { error: "Admins cannot promote to super admin." }, status: :forbidden
          end
        end
        attrs = user_params.to_h
        if attrs["subscription_plan"].present? && attrs["subscription_plan"] != user.subscription_plan
          if attrs["subscription_plan"] == "free"
            attrs["subscription_started_at"] = nil
            attrs["subscription_expires_at"] = nil
            attrs["razorpay_subscription_id"] = nil
          else
            attrs["subscription_started_at"] = Time.current
            attrs["subscription_expires_at"] = 1.month.from_now
          end
        end

        user.update!(attrs)
        log!("admin_updated_user", user, "Updated #{user.email}")
        render json: { user: admin_user_payload(user), audit_logs: audit_logs_payload }
      end

      def suspend_user
        return render json: { error: "You cannot suspend your own account." }, status: :forbidden if User.find(params[:id]) == current_user

        change_status!("suspended", "admin_suspended_user")
      end

      def activate_user
        change_status!("active", "admin_activated_user")
      end

      def promote_user
        user = User.find(params[:id])
        return render json: { error: "You cannot promote yourself." }, status: :forbidden if user == current_user
        return render json: { error: "Only super admins can promote to super admin." }, status: :forbidden if current_user.role == "admin"
        
        user.update!(role: "super_admin")
        log!("admin_promoted_user", user, "Promoted #{user.email} to super admin")
        render json: { user: admin_user_payload(user), audit_logs: audit_logs_payload }
      end

      def destroy_user
        user = User.find(params[:id])
        return render json: { error: "You cannot delete your own admin account." }, status: :unprocessable_entity if user == current_user

        log!("admin_deleted_user", user, "Deleted #{user.email}")
        user.destroy!
        render json: { users: users_payload, analytics: analytics, audit_logs: audit_logs_payload }
      end

      def update_settings
        setting = AdminSetting.find_or_initialize_by(key: params.require(:key))
        setting.value = params.fetch(:value, {})
        setting.save!
        log!("admin_updated_settings", current_user, "Updated #{setting.key}")
        render json: { settings: settings_payload, audit_logs: audit_logs_payload }
      end

      def export
        rows = export_rows(params[:kind])
        csv = CSV.generate(headers: true) do |out|
          out << rows.first.keys
          rows.each { |row| out << row.values }
        end
        send_data csv, filename: "admin-#{params[:kind] || "users"}-#{Date.current}.csv", type: "text/csv"
      end

      private

      def analytics
        {
          total_users: User.count,
          new_users_today: User.where(created_at: Time.current.all_day).count,
          active_users: User.where(status: "active").count,
          verified_users: User.where.not(verified_at: nil).count,
          total_resumes: Resume.count,
          draft_resumes: Resume.where(status: "draft").count,
          published_resumes: Resume.where(status: "published").count
        }
      end

      def resume_analytics
        total = Resume.count
        users = User.count
        top_template = Resume.group(:template_id).order(Arel.sql("COUNT(*) DESC")).limit(1).count.keys.first || "modern"
        {
          total_resumes: total,
          created_today: Resume.where(created_at: Time.current.all_day).count,
          downloaded_today: Resume.where(downloaded_at: Time.current.all_day).sum(:download_count),
          top_template: top_template.to_s.titleize,
          average_resumes_per_user: users.zero? ? 0 : (total.to_f / users).round(2)
        }
      end

      def feature_interest_analytics
        labels = {
          "ats_checker" => "ATS Checker",
          "mock_interviews" => "Mock Interviews",
          "portfolio_generator" => "Portfolio Gen",
          "job_tracker" => "Job Tracker"
        }
        fallback = { "ats_checker" => 120, "mock_interviews" => 85, "portfolio_generator" => 63, "job_tracker" => 44 }
        counts = FeatureInterest.group(:feature_key).count
        fallback.map do |key, count|
          { key: key, label: labels[key], interested: counts[key] || count }
        end
      end

      def subscription_analytics
        {
          free_users: User.where(subscription_plan: "free").count,
          pro_users: User.where(subscription_plan: "pro").count,
          team_users: User.where(subscription_plan: "team").count,
          revenue: PaymentOrder.where(status: "paid").sum(:amount_paise) / 100,
          monthly_revenue: PaymentOrder.where(status: "paid", activated_at: Time.current.beginning_of_month..).sum(:amount_paise) / 100,
          cancelled_plans: 0
        }
      end

      def settings_payload
        defaults = {
          "feature_flags" => { "ats_checker" => true, "mock_interview" => false, "portfolio_generator" => false },
          "maintenance_mode" => { "enabled" => false },
          "announcements" => { "message" => "Build resumes faster with polished templates." },
          "pricing_plans" => { "free" => 0, "pro" => 1, "team" => 2 }
        }
        stored = AdminSetting.all.index_by(&:key).transform_values(&:value)
        defaults.merge(stored)
      end

      def growth_payload
        months = (5.downto(0).map { |i| i.months.ago.beginning_of_month }).reverse
        {
          labels: months.map { |month| month.strftime("%b") },
          values: months.map { |month| User.where(created_at: month..month.end_of_month).count }
        }
      end

      def users_payload
        scope = User.order(created_at: :desc)
        if params[:search].present?
          q = "%#{params[:search].to_s.downcase}%"
          scope = scope.where("LOWER(email) LIKE :q OR LOWER(username) LIKE :q OR LOWER(first_name) LIKE :q OR LOWER(last_name) LIKE :q OR LOWER(role) LIKE :q", q: q)
        end
        paginated_payload(scope, params[:users_page]).merge(records: scope.limit(10).offset(page_offset(params[:users_page])).map { |user| admin_user_payload(user) })
      end

      def admin_user_payload(user)
        {
          id: user.id,
          name: user.full_name.presence || user.username,
          email: user.email,
          username: user.username,
          verified: user.verified?,
          role: user.role,
          created_at: user.created_at,
          last_login_at: user.last_login_at,
          status: user.status,
          subscription_plan: user.subscription_plan,
          subscription_started_at: user.subscription_started_at,
          subscription_expires_at: user.subscription_expires_at,
          free_downloads_remaining: user.free_downloads_remaining.finite? ? user.free_downloads_remaining : nil,
          resume_downloads_count: user.resume_downloads_count
        }
      end

      def audit_logs_payload
        scope = AuditLog.includes(:actor, :user).order(created_at: :desc)
        if params[:search].present?
          q = "%#{params[:search].to_s.downcase}%"
          scope = scope.where("LOWER(action) LIKE :q OR LOWER(details) LIKE :q", q: q)
        end
        paginated_payload(scope, params[:logs_page]).merge(records: scope.limit(10).offset(page_offset(params[:logs_page])).map do |log|
          {
            id: log.id,
            action: log.action.humanize,
            details: log.details,
            actor: log.actor&.email,
            user: log.user&.email,
            created_at: log.created_at
          }
        end)
      end

      def login_sessions_payload
        scope = LoginSession.includes(:user).order(logged_in_at: :desc)
        if params[:search].present?
          q = "%#{params[:search].to_s.downcase}%"
          scope = scope.joins(:user).where("LOWER(users.email) LIKE :q OR LOWER(users.username) LIKE :q OR LOWER(login_sessions.ip_address) LIKE :q", q: q)
        end
        paginated_payload(scope, params[:sessions_page]).merge(records: scope.limit(10).offset(page_offset(params[:sessions_page])).map do |session|
          {
            id: session.id,
            user: session.user.email,
            ip_address: session.ip_address,
            user_agent: session.user_agent,
            session_id: session.session_id,
            logged_in_at: session.logged_in_at,
            logged_out_at: session.logged_out_at
          }
        end)
      end

      def change_status!(status, action)
        user = User.find(params[:id])
        user.update!(status: status)
        log!(action, user, "#{user.email} is now #{status}")
        render json: { user: admin_user_payload(user), audit_logs: audit_logs_payload }
      end

      def log!(action, user, details)
        AuditLog.create!(actor: current_user, user: user, action: action, details: details)
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :role, :status, :subscription_plan, :verified_at)
      end

      def paginated_payload(scope, page_param)
        page = [page_param.to_i, 1].max
        total = scope.count
        { page: page, per_page: 10, total: total, total_pages: [(total / 10.0).ceil, 1].max }
      end

      def page_offset(page_param)
        ([page_param.to_i, 1].max - 1) * 10
      end

      def export_rows(kind)
        case kind
        when "resumes"
          Resume.includes(:user).order(created_at: :desc).map do |resume|
            { id: resume.id, title: resume.title, owner: resume.user.email, status: resume.status, template: resume.template_id, created_at: resume.created_at }
          end
        when "audit_logs"
          AuditLog.includes(:actor, :user).order(created_at: :desc).map do |log|
            { action: log.action, actor: log.actor&.email, user: log.user&.email, details: log.details, created_at: log.created_at }
          end
        else
          User.order(created_at: :desc).map do |user|
            { name: user.full_name, username: user.username, email: user.email, verified: user.verified?, role: user.role, status: user.status, subscription: user.subscription_plan, created_at: user.created_at, last_login: user.last_login_at }
          end
        end
      end
    end
  end
end
