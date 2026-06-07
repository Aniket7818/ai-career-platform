module Api
  module V1
    class ComingSoonController < ApplicationController
      def show
        interest_counts = FeatureInterest.group(:feature_key).count
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
