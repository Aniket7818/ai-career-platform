require "openssl"
require "securerandom"
require "net/http"
require "json"

module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate_api_user!

      def create
        plan = params.require(:plan).to_s
        billing_cycle = params[:billing_cycle] == "yearly" ? "yearly" : "monthly"
        return render json: { error: "Free plan does not need payment." }, status: :unprocessable_entity if plan == "free"
        return render json: { error: "Unknown plan." }, status: :unprocessable_entity unless PaymentOrder::PLANS.key?(plan)

        order = current_user.payment_orders.create!(plan: plan, metadata: { source: "checkout", billing_cycle: billing_cycle })
        order.update!(razorpay_order_id: create_razorpay_order(order))

        render json: {
          order: payment_order_payload(order),
          razorpay_key_id: ENV["RAZORPAY_KEY_ID"].presence || ENV["VITE_RAZORPAY_KEY_ID"].presence
        }, status: :created
      end

      def verify
        order = current_user.payment_orders.find_by!(razorpay_order_id: params.require(:razorpay_order_id))
        order.assign_attributes(
          razorpay_payment_id: params[:razorpay_payment_id].presence || "manual_#{SecureRandom.hex(8)}",
          razorpay_signature: params[:razorpay_signature]
        )

        if razorpay_secret.present? && order.razorpay_signature.present?
          expected = OpenSSL::HMAC.hexdigest("SHA256", razorpay_secret, "#{order.razorpay_order_id}|#{order.razorpay_payment_id}")
          return render json: { error: "Payment signature could not be verified." }, status: :unprocessable_entity unless secure_compare(expected, order.razorpay_signature)
        end

        order.activate!
        
        # Create billing history record
        billing_history = current_user.billing_histories.create!(
          plan_name: order.plan,
          amount: order.amount_paise / 100.0,
          currency: order.currency,
          payment_provider: "Razorpay",
          payment_id: order.razorpay_payment_id,
          order_id: order.razorpay_order_id,
          invoice_number: "INV-#{Time.current.year}-#{SecureRandom.hex(3).upcase}",
          billing_cycle: order.metadata&.dig("billing_cycle") || "monthly",
          payment_status: "Paid",
          paid_at: Time.current,
          renewal_date: current_user.subscription_expires_at
        )

        InvoiceGeneratorService.new(billing_history, current_user).generate_pdfs!

        # Send activation email asynchronously (does not block payment flow)
        SubscriptionMailer.with(user: current_user, billing_history: billing_history).activated.deliver_later

        render json: { user: UserSerializer.new(current_user.reload).as_json, order: payment_order_payload(order) }
      end

      def destroy
        AuditLog.create!(
          actor: current_user,
          user: current_user,
          action: "cancelled_subscription",
          details: "User cancelled their #{current_user.subscription_plan} plan"
        )
        current_user.update!(subscription_plan: 'free', subscription_expires_at: nil, razorpay_subscription_id: nil)
        render json: { user: UserSerializer.new(current_user).as_json, message: "Subscription cancelled." }
      end

      private

      def payment_order_payload(order)
        {
          id: order.id,
          plan: order.plan,
          amount_paise: order.amount_paise,
          amount: order.amount_paise / 100.0,
          currency: order.currency,
          status: order.status,
          razorpay_order_id: order.razorpay_order_id
        }
      end

      def razorpay_secret
        ENV["RAZORPAY_KEY_SECRET"].presence || ENV["RAZORPAY_SECRET"].presence
      end

      def razorpay_key_id
        ENV["RAZORPAY_KEY_ID"].presence || ENV["VITE_RAZORPAY_KEY_ID"].presence
      end

      def create_razorpay_order(order)
        return "order_#{SecureRandom.hex(10)}" if razorpay_key_id.blank? || razorpay_secret.blank?

        uri = URI("https://api.razorpay.com/v1/orders")
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(razorpay_key_id, razorpay_secret)
        request["Content-Type"] = "application/json"
        request.body = {
          amount: order.amount_paise,
          currency: order.currency,
          receipt: "careerai_#{order.id}",
          notes: { user_id: current_user.id, plan: order.plan }
        }.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
        body = JSON.parse(response.body)
        raise "Razorpay order creation failed: #{body["error"]&.dig("description") || response.body}" unless response.is_a?(Net::HTTPSuccess)

        body.fetch("id")
      end

      def secure_compare(expected, actual)
        ActiveSupport::SecurityUtils.secure_compare(expected, actual.to_s)
      rescue ArgumentError
        false
      end
    end
  end
end
