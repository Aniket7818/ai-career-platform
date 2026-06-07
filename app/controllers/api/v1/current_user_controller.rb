module Api
  module V1
    class CurrentUserController < ApplicationController
      before_action :authenticate_api_user!

      def show
        render json: { user: UserSerializer.new(current_user).as_json }, status: :ok
      end
    end
  end
end
