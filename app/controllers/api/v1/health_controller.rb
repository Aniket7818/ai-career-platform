module Api
  module V1
    class HealthController < ApplicationController
      def show
        render json: { status: "ok", timestamp: Time.now.to_i }
      end
    end
  end
end
