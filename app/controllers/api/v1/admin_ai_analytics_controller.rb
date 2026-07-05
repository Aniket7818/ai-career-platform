module Api
  module V1
    class AdminAiAnalyticsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_admin!
      require 'csv'

      def show
        time_range = (params[:days] || 30).to_i.days.ago.beginning_of_day..Time.current
        
        # Base queries
        base_logs = AiLog.where(created_at: time_range)
        success_logs = base_logs.where(status: "success")
        
        today_range = Time.current.beginning_of_day..Time.current
        yesterday_range = 1.day.ago.beginning_of_day..1.day.ago.end_of_day
        this_month_range = Time.current.beginning_of_month..Time.current
        
        total_requests_count = base_logs.count
        
        # 1. Overview Stats
        overview = {
          total_requests: total_requests_count,
          today_requests: base_logs.where(created_at: today_range).count,
          yesterday_requests: base_logs.where(created_at: yesterday_range).count,
          monthly_requests: base_logs.where(created_at: this_month_range).count,
          
          successful_requests: success_logs.count,
          failed_requests: base_logs.where(status: "failed").count,
          rejected_requests: base_logs.where(status: "rejected").count,
          cancelled_requests: base_logs.where(status: "cancelled").count, # If any
          timed_out_requests: base_logs.where("error_message ILIKE ?", "%timeout%").count,
          duplicate_blocked: base_logs.where(failure_reason: "duplicate_request").count,
          
          cache_hits: base_logs.where(cache_hit: true).count,
          cache_misses: base_logs.where(cache_hit: [false, nil]).count,
          cache_hit_percentage: total_requests_count > 0 ? (base_logs.where(cache_hit: true).count.to_f / total_requests_count * 100).round(2) : 0,
          
          avg_response_time: success_logs.average(:response_time).to_f.round(2),
          median_response_time: median(success_logs.pluck(:response_time)),
          
          avg_tokens: (success_logs.average(:tokens_in).to_f + success_logs.average(:tokens_out).to_f).round(2),
          avg_cost: success_logs.count > 0 ? (success_logs.sum(:estimated_cost).to_f / success_logs.count).round(5) : 0,
          
          total_credits_consumed: success_logs.sum(:credits_used).to_i,
          today_credits: success_logs.where(created_at: today_range).sum(:credits_used).to_i,
          monthly_credits: success_logs.where(created_at: this_month_range).sum(:credits_used).to_i,
          
          active_ai_users: base_logs.select(:user_id).distinct.count,
          unique_users_today: base_logs.where(created_at: today_range).select(:user_id).distinct.count,
          
          most_used_feature: base_logs.group(:feature).order("count_all DESC").limit(1).count.keys.first,
          most_used_provider: base_logs.group(:provider).order("count_all DESC").limit(1).count.keys.first || "Legacy / Not Recorded",
          most_used_model: base_logs.group(:model).order("count_all DESC").limit(1).count.keys.first,
          
          total_cost: success_logs.sum(:estimated_cost).to_f.round(5),
          today_cost: success_logs.where(created_at: today_range).sum(:estimated_cost).to_f.round(5),
          yesterday_cost: success_logs.where(created_at: yesterday_range).sum(:estimated_cost).to_f.round(5),
          this_month_cost: success_logs.where(created_at: this_month_range).sum(:estimated_cost).to_f.round(5),
          lifetime_cost: AiLog.where(status: 'success').sum(:estimated_cost).to_f.round(5)
        }
        
        # 2. Provider Analytics
        provider_stats = base_logs.group(:provider).select(
          "provider",
          "COUNT(*) as total_requests",
          "SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful_requests",
          "SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_requests",
          "AVG(NULLIF(response_time, 0)) as avg_time",
          "AVG(NULLIF(tokens_in, 0)) as avg_in_tokens",
          "AVG(NULLIF(tokens_out, 0)) as avg_out_tokens",
          "AVG(NULLIF(estimated_cost, 0)) as avg_cost",
          "SUM(estimated_cost) as total_cost",
          "SUM(CASE WHEN error_message ILIKE '%timeout%' THEN 1 ELSE 0 END) as timeout_count",
          "SUM(CASE WHEN failure_reason IN ('unauthorized', 'authentication') THEN 1 ELSE 0 END) as auth_errors",
          "SUM(CASE WHEN failure_reason = 'rate_limited' THEN 1 ELSE 0 END) as rate_limits"
        ).map do |p|
          total_req = p.total_requests.to_i
          success_req = p.successful_requests.to_i
          failed_req = p.failed_requests.to_i
          
          {
            name: p.provider || "Legacy / Not Recorded",
            total_requests: total_req,
            successful_requests: success_req,
            failed_requests: failed_req,
            avg_time: p.avg_time.to_f.round(2),
            avg_in_tokens: p.avg_in_tokens.to_f.round(2),
            avg_out_tokens: p.avg_out_tokens.to_f.round(2),
            avg_total_tokens: (p.avg_in_tokens.to_f + p.avg_out_tokens.to_f).round(2),
            avg_cost: p.avg_cost.to_f.round(5),
            total_cost: p.total_cost.to_f.round(5),
            timeout_count: p.timeout_count.to_i,
            auth_errors: p.auth_errors.to_i,
            rate_limits: p.rate_limits.to_i,
            provider_errors: failed_req,
            success_percentage: total_req > 0 ? (success_req.to_f / total_req * 100).round(2) : 0,
            failure_percentage: total_req > 0 ? (failed_req.to_f / total_req * 100).round(2) : 0,
            avg_daily_requests: (total_req.to_f / [1, (Time.current - time_range.begin).to_i / 1.day].max).round(2)
          }
        end
        
        # 3. AI Feature Analytics
        feature_stats = base_logs.group(:feature).select(
          "feature",
          "COUNT(*) as total_requests",
          "SUM(credits_used) as total_credits",
          "AVG(NULLIF(tokens_in + tokens_out, 0)) as avg_tokens",
          "AVG(NULLIF(estimated_cost, 0)) as avg_cost",
          "AVG(NULLIF(response_time, 0)) as avg_time",
          "SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_requests",
          "SUM(CASE WHEN cache_hit = true THEN 1 ELSE 0 END) as cache_hits",
          "MAX(created_at) as last_used"
        ).map do |f|
          total_req = f.total_requests.to_i
          {
            name: f.feature,
            requests: total_req,
            credits_used: f.total_credits.to_i,
            avg_tokens: f.avg_tokens.to_f.round(2),
            avg_cost: f.avg_cost.to_f.round(5),
            avg_time: f.avg_time.to_f.round(2),
            failure_rate: total_req > 0 ? (f.failed_requests.to_f / total_req * 100).round(2) : 0,
            cache_hit_rate: total_req > 0 ? (f.cache_hits.to_f / total_req * 100).round(2) : 0,
            most_used_provider: base_logs.where(feature: f.feature).group(:provider).order("count_all DESC").limit(1).count.keys.first || "Legacy / Not Recorded",
            last_used: f.last_used
          }
        end
        
        # 5. Cost Analytics Details
        cost_by_user = success_logs.group(:user_id).sum(:estimated_cost).values.sum / [1, success_logs.select(:user_id).distinct.count].max
        
        cost_analytics = {
          avg_cost_per_request: overview[:avg_cost],
          avg_cost_per_user: cost_by_user.to_f.round(5),
          avg_cost_per_feature: feature_stats.size > 0 ? (overview[:total_cost] / feature_stats.size).round(5) : 0,
          estimated_monthly_cost: (overview[:this_month_cost] / [1, Time.current.day].max * Time.days_in_month(Time.current.month)).round(2),
          cache_savings: (overview[:cache_hits] * overview[:avg_cost]).round(5)
        }
        
        # 6. Token Analytics
        token_analytics = {
          input_tokens: success_logs.sum(:tokens_in).to_i,
          output_tokens: success_logs.sum(:tokens_out).to_i,
          avg_tokens: overview[:avg_tokens],
          largest_prompt: success_logs.maximum(:tokens_in).to_i,
          largest_response: success_logs.maximum(:tokens_out).to_i,
          avg_prompt_size: success_logs.average(:tokens_in).to_f.round(2),
          avg_response_size: success_logs.average(:tokens_out).to_f.round(2)
        }
        
        # 7. Performance Analytics
        response_times = success_logs.where.not(response_time: nil).pluck(:response_time).sort
        p95_index = (response_times.size * 0.95).round - 1
        p95 = response_times[p95_index] || 0
        
        performance_analytics = {
          avg_response_time: overview[:avg_response_time],
          median_response_time: overview[:median_response_time],
          p95_response_time: p95,
          fastest_request: response_times.first || 0,
          slowest_request: response_times.last || 0,
          slowest_requests_list: success_logs.where.not(response_time: nil).order(response_time: :desc).limit(5).map { |l| { id: l.request_id, feature: l.feature, response_time: l.response_time, user: l.user.email } }
        }
        
        # 8. Failure Analytics
        failures = base_logs.where.not(status: 'success').group(:status, :failure_reason).count.map do |(status, reason), count|
          { status: status, reason: reason || 'unknown', count: count }
        end
        
        # 9. Cache Analytics
        cache_analytics = {
          cache_hits: overview[:cache_hits],
          cache_misses: overview[:cache_misses],
          hit_rate: overview[:cache_hit_percentage],
          estimated_money_saved: cost_analytics[:cache_savings],
          estimated_credits_saved: base_logs.where(cache_hit: true).sum(:credits_used).to_i,
          most_cached_feature: base_logs.where(cache_hit: true).group(:feature).order("count_all DESC").limit(1).count.keys.first,
          least_cached_feature: base_logs.where(cache_hit: false).group(:feature).order("count_all ASC").limit(1).count.keys.first
        }
        
        # Charts Data
        daily_requests = base_logs.group("DATE(created_at)").count.map { |date, c| { date: date, count: c } }
        daily_cost = success_logs.group("DATE(created_at)").sum(:estimated_cost).map { |date, cost| { date: date, cost: cost.to_f.round(5) } }
        daily_tokens = success_logs.group("DATE(created_at)").sum("tokens_in + tokens_out").map { |date, tokens| { date: date, tokens: tokens.to_i } }
        daily_failures = base_logs.where.not(status: 'success').group("DATE(created_at)").count.map { |date, c| { date: date, count: c } }
        
        charts = {
          daily_requests: daily_requests,
          daily_cost: daily_cost,
          daily_tokens: daily_tokens,
          daily_failures: daily_failures,
          daily_credits: success_logs.group("DATE(created_at)").sum(:credits_used).map { |date, c| { date: date, count: c.to_i } },
          hourly_requests: base_logs.where("created_at > ?", 24.hours.ago).group("EXTRACT(HOUR FROM created_at)").count.map { |hour, c| { hour: hour.to_i, count: c } }.sort_by { |h| h[:hour] }
        }

        # 10. Live Activity
        recent_activity = base_logs.includes(:user, :resume).order(created_at: :desc).limit(15).map do |log|
          {
            id: log.id,
            time: log.created_at,
            user_email: log.user.email,
            resume: log.resume&.title || "Unknown",
            feature: log.feature,
            provider: log.provider || "Legacy / Not Recorded",
            model: log.model,
            credits: log.credits_used,
            input_tokens: log.tokens_in,
            output_tokens: log.tokens_out,
            cost: log.estimated_cost,
            time_ms: log.response_time,
            status: log.status,
            ip: log.ip_address,
            request_id: log.request_id,
            fingerprint: log.fingerprint
          }
        end
        
        # 11. Most Expensive Users
        most_expensive_users = success_logs.joins(:user).group("users.email").sum(:estimated_cost).sort_by { |_, cost| -cost.to_f }.first(5).map do |email, cost|
          { email: email, cost: cost.to_f.round(5) }
        end
        
        render json: {
          success: true,
          analytics: {
            overview: overview,
            provider_stats: provider_stats,
            feature_stats: feature_stats,
            cost_analytics: cost_analytics,
            token_analytics: token_analytics,
            performance_analytics: performance_analytics,
            failure_analytics: failures,
            cache_analytics: cache_analytics,
            charts: charts,
            recent_activity: recent_activity,
            most_expensive_users: most_expensive_users
          }
        }
      end

      # 4. User Analytics
      def users
        page = (params[:page] || 1).to_i
        per_page = params[:per_page] || 10
        
        query = User.joins(:ai_logs).group("users.id").select(
          "users.id",
          "users.email",
          "users.subscription_plan",
          "COUNT(ai_logs.id) as total_requests",
          "SUM(CASE WHEN ai_logs.status = 'success' THEN 1 ELSE 0 END) as successful_requests",
          "SUM(CASE WHEN ai_logs.status != 'success' THEN 1 ELSE 0 END) as failed_requests",
          "SUM(ai_logs.credits_used) as total_credits",
          "AVG(NULLIF(ai_logs.tokens_in + ai_logs.tokens_out, 0)) as avg_tokens",
          "AVG(NULLIF(ai_logs.estimated_cost, 0)) as avg_cost",
          "MAX(ai_logs.created_at) as last_activity"
        )
        
        if params[:search].present?
          query = query.where("users.email ILIKE ?", "%#{params[:search]}%")
        end
        
        # Sorting
        if params[:sort_by] == 'credits'
          query = query.order("total_credits DESC")
        elsif params[:sort_by] == 'cost'
          query = query.order("avg_cost DESC")
        else
          query = query.order("total_requests DESC")
        end
        
        total_pages = (query.to_a.size / per_page.to_f).ceil
        
        leaderboard = query.offset((page - 1) * per_page).limit(per_page).map do |u|
          most_used_feature = AiLog.where(user_id: u.id).group(:feature).order("count_all DESC").limit(1).count.keys.first
          most_used_provider = AiLog.where(user_id: u.id).group(:provider).order("count_all DESC").limit(1).count.keys.first
          
          {
            id: u.id,
            email: u.email,
            subscription_plan: u.subscription_plan,
            total_requests: u.total_requests.to_i,
            successful_requests: u.successful_requests.to_i,
            failed_requests: u.failed_requests.to_i,
            credits_used: u.total_credits.to_i,
            avg_tokens: u.avg_tokens.to_f.round(2),
            avg_cost: u.avg_cost.to_f.round(5),
            last_activity: u.last_activity,
            most_used_feature: most_used_feature,
            most_used_provider: most_used_provider
          }
        end
        
        render json: {
          success: true,
          leaderboard: leaderboard,
          pagination: {
            current_page: page,
            total_pages: total_pages > 0 ? total_pages : 1
          }
        }
      end

      # 11. AI Request Explorer
      def requests
        page = (params[:page] || 1).to_i
        per_page = 20
        query = AiLog.includes(:user, :resume)

        sort_col = %w[created_at feature provider model estimated_cost response_time tokens_in].include?(params[:sort_by]) ? params[:sort_by] : "created_at"
        sort_dir = params[:sort_dir] == "asc" ? "asc" : "desc"
        query = query.order("ai_logs.#{sort_col} #{sort_dir}")
        
        if params[:search].present?
          query = query.joins(:user).where(
            "users.email ILIKE :search OR users.first_name ILIKE :search OR users.last_name ILIKE :search OR ai_logs.feature ILIKE :search OR ai_logs.provider ILIKE :search OR ai_logs.model ILIKE :search OR ai_logs.status ILIKE :search OR ai_logs.request_id = :exact OR ai_logs.fingerprint ILIKE :search",
            search: "%#{params[:search]}%", exact: params[:search]
          )
        end
        if params[:provider].present?
          query = query.where(provider: params[:provider])
        end
        if params[:feature].present?
          query = query.where(feature: params[:feature])
        end
        if params[:status].present?
          query = query.where(status: params[:status])
        end
        if params[:date].present?
          date = Date.parse(params[:date]) rescue nil
          query = query.where("ai_logs.created_at" => date.beginning_of_day..date.end_of_day) if date
        end
        if params[:subscription].present?
          query = query.joins(:user).where(users: { subscription_plan: params[:subscription] })
        end
        
        total_pages = (query.count / per_page.to_f).ceil
        logs = query.offset((page - 1) * per_page).limit(per_page).map do |log|
          {
            id: log.id,
            request_id: log.request_id,
            created_at: log.created_at,
            updated_at: log.updated_at,
            user_email: log.user.email,
            resume: log.resume&.title,
            feature: log.feature,
            provider: log.provider || "Legacy / Not Recorded",
            model: log.model,
            prompt_version: log.prompt_version,
            status: log.status,
            credits: log.credits_used,
            input_tokens: log.tokens_in,
            output_tokens: log.tokens_out,
            cost: log.estimated_cost,
            duration: log.response_time,
            cache_hit: log.cache_hit,
            retry_count: log.retry_count,
            fingerprint: log.fingerprint,
            ip: log.ip_address,
            system_prompt: extract_system_prompt(log.request_prompt),
            user_prompt: extract_user_prompt(log.request_prompt),
            response_content: log.response_content,
            error_message: log.error_message,
            failure_reason: log.failure_reason,
            raw_request_json: log.raw_request_json,
            raw_response_json: log.raw_response_json,
            performance_events: log.performance_events,
            provider_headers: log.provider_headers,
            provider_request_id: log.provider_request_id,
            finish_reason: log.finish_reason,
            http_status: log.http_status
          }
        end
        
        render json: {
          success: true,
          requests: logs,
          pagination: {
            current_page: page,
            total_pages: total_pages > 0 ? total_pages : 1,
            total_count: query.count
          }
        }
      end

      # 12. AI Request Details
      def request_details
        log = AiLog.includes(:user).find(params[:id])
        render json: {
          success: true,
          request: log.as_json.merge(
            user_email: log.user.email,
            system_prompt: extract_system_prompt(log.request_prompt),
            user_prompt: extract_user_prompt(log.request_prompt)
          )
        }
      end

      # 14. Export
      def export
        kind = params[:kind]
        csv_data = ""
        filename = "ai_export_#{kind}_#{Date.today}.csv"
        
        case kind
        when 'requests'
          query = AiLog.includes(:user)
          
          if params[:search].present?
            query = query.joins(:user).where(
              "users.email ILIKE :search OR users.first_name ILIKE :search OR users.last_name ILIKE :search OR ai_logs.feature ILIKE :search OR ai_logs.provider ILIKE :search OR ai_logs.model ILIKE :search OR ai_logs.status ILIKE :search OR ai_logs.request_id = :exact OR ai_logs.fingerprint ILIKE :search",
              search: "%#{params[:search]}%", exact: params[:search]
            )
          end
          query = query.where(provider: params[:provider]) if params[:provider].present?
          query = query.where(feature: params[:feature]) if params[:feature].present?
          query = query.where(status: params[:status]) if params[:status].present?
          if params[:date].present?
            date = Date.parse(params[:date]) rescue nil
            query = query.where("ai_logs.created_at" => date.beginning_of_day..date.end_of_day) if date
          end
          
          logs = query.order("ai_logs.created_at" => :desc).limit(1000)
          csv_data = CSV.generate(headers: true) do |csv|
            csv << ['Request ID', 'Created At', 'User Email', 'Feature', 'Provider', 'Model', 'Status', 'Cost', 'Duration (ms)', 'Tokens In', 'Tokens Out', 'Cache Hit']
            logs.each do |log|
              csv << [log.request_id, log.created_at, log.user.email, log.feature, log.provider, log.model, log.status, log.estimated_cost, log.response_time, log.tokens_in, log.tokens_out, log.cache_hit]
            end
          end
        when 'users'
          # Simple export of user leaderboard
          users = User.joins(:ai_logs).group("users.id, users.email").select("users.email, COUNT(ai_logs.id) as req_count, SUM(ai_logs.estimated_cost) as total_cost").limit(1000)
          csv_data = CSV.generate(headers: true) do |csv|
            csv << ['Email', 'Total Requests', 'Total Cost']
            users.each do |u|
              csv << [u.email, u.req_count, u.total_cost]
            end
          end
        else
          return render json: { success: false, error: "Invalid export kind" }, status: :bad_request
        end
        
        send_data csv_data, filename: filename, type: 'text/csv'
      end

      private

      def ensure_admin!
        unless current_user&.role&.in?(%w[admin super_admin])
          render json: { success: false, error: "Unauthorized" }, status: :forbidden
        end
      end
      
      def median(array)
        return 0 if array.empty?
        sorted = array.sort
        len = sorted.length
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
      end
      
      def extract_system_prompt(prompt_text)
        return "" unless prompt_text
        if prompt_text.include?("system:")
          prompt_text.split("user:").first&.gsub("system:", "")&.strip
        else
          "N/A"
        end
      end
      
      def extract_user_prompt(prompt_text)
        return prompt_text unless prompt_text
        if prompt_text.include?("user:")
          prompt_text.split("user:").last&.strip
        else
          prompt_text
        end
      end
    end
  end
end
