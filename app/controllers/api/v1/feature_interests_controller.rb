module Api
  module V1
    class FeatureInterestsController < ApplicationController
      def create
        interest = build_interest

        if interest.save
          count = FeatureInterest.for_feature(interest.feature_key).count
          render json: FeatureInterestSerializer.new(interest, interest_count: count).as_json, status: :created
        else
          render json: { errors: friendly_validation_errors(interest) }, status: :unprocessable_entity
        end
      end

      def destroy
        interest = find_interest
        feature_key = interest.feature_key
        interest.destroy
        count = FeatureInterest.for_feature(feature_key).count
        render json: { feature_key: feature_key, interest_count: count, notified: false }
      end

      private

      def build_interest
        if current_user
          current_user.feature_interests.find_or_initialize_by(feature_key: interest_params[:feature_key])
        else
          FeatureInterest.find_or_initialize_by(
            email: interest_params[:email],
            feature_key: interest_params[:feature_key]
          )
        end
      end

      def find_interest
        if current_user
          current_user.feature_interests.find_by!(feature_key: destroy_params[:feature_key])
        else
          FeatureInterest.find_by!(
            email: destroy_params[:email].to_s.strip.downcase,
            feature_key: destroy_params[:feature_key]
          )
        end
      end

      def interest_params
        params.require(:feature_interest).permit(:feature_key, :email)
      end

      def destroy_params
        params.require(:feature_interest).permit(:feature_key, :email)
      end
    end
  end
end
