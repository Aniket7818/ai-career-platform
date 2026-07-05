module Api
  module V1
    class CreditsController < ApplicationController
      before_action :authenticate_api_user!

      def history
        page = [ params.fetch(:page, 1).to_i, 1 ].max
        per_page = [ params.fetch(:per_page, 20).to_i, 100 ].min

        transactions = current_user.credit_transactions
                                   .order(created_at: :desc)
                                   .limit(per_page)
                                   .offset((page - 1) * per_page)

        total_count = current_user.credit_transactions.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          transactions: transactions,
          meta: {
            current_page: page,
            per_page: per_page,
            total_pages: total_pages,
            total_count: total_count
          }
        }
      end
    end
  end
end
