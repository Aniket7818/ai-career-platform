module Api
  module V1
    class PricingController < ApplicationController
      # Public endpoint to retrieve plan pricing dynamically based on Payment Test Mode status
      def index
        mode = PricingService.current_mode
        plans = PricingService.plans

        render json: {
          mode: mode,
          plans: {
            free: { monthly: 0, yearly: 0, credits: 10 },
            plus: { monthly: plans[:plus][:monthly], yearly: plans[:plus][:yearly], credits: 150 },
            pro: { monthly: plans[:pro][:monthly], yearly: plans[:pro][:yearly], credits: 500 }
          }
        }
      end
    end
  end
end
