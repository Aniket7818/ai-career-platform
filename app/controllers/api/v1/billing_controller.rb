module Api
  module V1
    class BillingController < ApplicationController
      before_action :authenticate_api_user!

      def history
        records = current_user.billing_histories.order(created_at: :desc)
        render json: { billing_history: records }
      end

      def invoice
        history = current_user.billing_histories.find(params[:id])
        return head :not_found unless history.invoice_pdf_path && File.exist?(history.invoice_pdf_path)
        send_file history.invoice_pdf_path, type: "application/pdf", disposition: "attachment"
      end

      def receipt
        history = current_user.billing_histories.find(params[:id])
        return head :not_found unless history.receipt_pdf_path && File.exist?(history.receipt_pdf_path)
        send_file history.receipt_pdf_path, type: "application/pdf", disposition: "attachment"
      end
    end
  end
end
