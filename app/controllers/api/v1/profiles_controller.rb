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

      def change_password
        user = current_user
        if user.update_with_password(password_params)
          bypass_sign_in(user)
          render json: { message: "Password updated successfully." }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        current_user.destroy!
        render json: { message: "Account deleted successfully." }, status: :ok
      end

      private

      def profile_params
        params.require(:user).permit(:first_name, :last_name, :title, :location, :phone, :website, :linkedin, :github, :bio, :avatar, :cover_image)
      end

      def password_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
      end
    end
  end
end
