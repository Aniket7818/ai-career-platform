module Api
  module V1
    class AdminAiAnalyticsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_admin!

      def show
        time_range = (params[:days] || 30).to_i.days.ago..Time.current

        # Base queries
        base_logs = AiLog.where(created_at: time_range)
        success_logs = base_logs.where(status: "success")

        # Overview Stats
        overview = {
          total_requests: base_logs.count,
          today_requests: base_logs.where(created_at: 1.day.ago..Time.current).count,
          successful_requests: success_logs.count,
          failed_requests: base_logs.where(status: "failed").count,
          rejected_requests: base_logs.where(status: "rejected").count,
          cache_hits: base_logs.where(cache_hit: true).count,
          avg_response_time: success_logs.average(:response_time).to_f.round(2),
          avg_tokens: (success_logs.average(:tokens_in).to_f + success_logs.average(:tokens_out).to_f).round(2),
          total_cost: success_logs.sum(:estimated_cost).to_f.round(5),
          today_cost: success_logs.where(created_at: 1.day.ago..Time.current).sum(:estimated_cost).to_f.round(5)
        }

        # Provider Analytics
        providers = base_logs.group(:provider).count.map { |p, c| { name: p || "unknown", count: c } }
        provider_stats = success_logs.group(:provider).select(
          "provider",
          "AVG(response_time) as avg_time",
          "AVG(estimated_cost) as avg_cost"
        ).map do |p|
          {
            name: p.provider || "unknown",
            avg_time: p.avg_time.to_f.round(2),
            avg_cost: p.avg_cost.to_f.round(5)
          }
        end

        # Feature Analytics
        features = base_logs.group(:feature).count.map { |f, c| { name: f, count: c } }
        feature_stats = success_logs.group(:feature).select(
          "feature",
          "AVG(response_time) as avg_time",
          "AVG(estimated_cost) as avg_cost",
          "SUM(estimated_cost) as total_cost"
        ).map do |f|
          {
            name: f.feature,
            avg_time: f.avg_time.to_f.round(2),
            avg_cost: f.avg_cost.to_f.round(5),
            total_cost: f.total_cost.to_f.round(5)
          }
        end

        # Cost Trend (Daily)
        cost_trend = success_logs.group("DATE(created_at)").sum(:estimated_cost).map { |date, cost| { date: date, cost: cost.to_f.round(5) } }

        # Live Activity (Recent 10)
        recent = base_logs.includes(:user).order(created_at: :desc).limit(10).map do |log|
          {
            id: log.id,
            time: log.created_at,
            user_email: log.user.email,
            feature: log.feature,
            provider: log.provider,
            model: log.model,
            credits: log.credits_used,
            cost: log.estimated_cost,
            status: log.status,
            time_ms: log.response_time
          }
        end

        render json: {
          success: true,
          analytics: {
            overview: overview,
            providers: providers,
            provider_stats: provider_stats,
            features: features,
            feature_stats: feature_stats,
            cost_trend: cost_trend,
            recent_activity: recent
          }
        }
      end

      def requests
        page = (params[:page] || 1).to_i
        per_page = 20
        query = AiLog.includes(:user).order(created_at: :desc)

        if params[:search].present?
          query = query.joins(:user).where("users.email ILIKE ? OR ai_logs.feature ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        end

        if params[:provider].present?
          query = query.where(provider: params[:provider])
        end

        total_pages = (query.count / per_page.to_f).ceil
        logs = query.offset((page - 1) * per_page).limit(per_page).map do |log|
          {
            id: log.id,
            time: log.created_at,
            user_email: log.user.email,
            feature: log.feature,
            provider: log.provider,
            model: log.model,
            status: log.status,
            cost: log.estimated_cost,
            tokens: (log.tokens_in.to_i + log.tokens_out.to_i)
          }
        end

        render json: {
          success: true,
          requests: logs,
          pagination: {
            current_page: page,
            total_pages: total_pages
          }
        }
      end

      def request_details
        log = AiLog.includes(:user).find(params[:id])
        render json: {
          success: true,
          request: log.as_json.merge(user_email: log.user.email)
        }
      end

      private

      def ensure_admin!
        unless current_user.admin?
          render json: { success: false, error: "Unauthorized" }, status: :forbidden
        end
      end
    end
  end
end
