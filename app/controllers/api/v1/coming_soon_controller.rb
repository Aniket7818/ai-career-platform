module Api
  module V1
    class ComingSoonController < ApplicationController
      def show
        actual_counts = FeatureInterest.group(:feature_key).count
        interest_counts = fake_interest_counts(actual_counts)
        user_interests = current_user_interests
        trend_data = build_trend_data(interest_counts)

        render json: ComingSoonSerializer.new(
          interest_counts: interest_counts,
          user_interests: user_interests,
          trend_data: trend_data
        ).as_json
      end

      private

      def current_user_interests
        return [] unless current_user

        current_user.feature_interests.pluck(:feature_key)
      end

      def fake_interest_counts(actual_counts)
        base_time = Time.new(2026, 6, 1).to_i
        intervals = [(Time.now.to_i - base_time) / 300, 0].max
        
        jitter = Random.new(intervals).rand(10)
        fake_total = 5000 + (intervals * 5.5).to_i + jitter

        feature_keys = UpcomingFeatures::DEFINITIONS.map { |f| f[:key] }
        
        dist_rng = Random.new(42)
        weights = feature_keys.map { dist_rng.rand(10..100) }
        total_weight = weights.sum.to_f
        
        faked_counts = {}
        feature_keys.each_with_index do |key, i|
          base_fake = (fake_total * weights[i] / total_weight).to_i
          faked_counts[key] = base_fake + (actual_counts[key] || 0)
        end
        
        faked_counts
      end

      def build_trend_data(interest_counts)
        total = interest_counts.values.sum
        base = [total * 0.55, total * 0.62, total * 0.71, total * 0.78, total * 0.84, total * 0.91, total].map(&:round)
        {
          labels: %w[Mon Tue Wed Thu Fri Sat Sun],
          values: base
        }
      end
    end
  end
end
