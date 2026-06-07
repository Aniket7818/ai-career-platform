module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_user!

      def show
        render json: { user: UserSerializer.new(current_user).as_json }
      end

      def update
        if current_user.update(profile_params)
          render json: { user: UserSerializer.new(current_user).as_json }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:user).permit(:first_name, :last_name, :title, :location, :phone, :website, :linkedin, :github, :bio, :avatar, :cover_image)
      end
    end
  end
end
