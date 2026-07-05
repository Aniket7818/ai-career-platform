class PaymentOrder < ApplicationRecord
  PLANS = {
    "plus" => { monthly_paise: 100, yearly_paise: 200, label: "CareerAI Plus" },
    "pro" => { monthly_paise: 300, yearly_paise: 400, label: "CareerAI Pro" },
    "team" => { monthly_paise: 500, yearly_paise: 500, label: "Team (Legacy)" }
  }.freeze

  belongs_to :user

  validates :plan, inclusion: { in: PLANS.keys }
  validates :status, inclusion: { in: %w[created paid failed] }
  validates :amount_paise, numericality: { greater_than: 0 }

  before_validation :set_amount, on: :create

  def self.plan_amount(plan, billing_cycle)
    PricingService.plan_price_in_paise(plan, billing_cycle)
  end

  def activate!
    transaction do
      update!(status: "paid", activated_at: Time.current)
      cycle = metadata["billing_cycle"] || "monthly"
      expires_in = cycle == "yearly" ? 1.year : 1.month

      credits = { "plus" => 150, "pro" => 500, "team" => 1000 }.fetch(plan, 150)

      user.update!(
        subscription_plan: plan,
        subscription_started_at: Time.current,
        subscription_expires_at: expires_in.from_now,
        razorpay_subscription_id: razorpay_order_id,
        monthly_credit_limit: credits,
        remaining_credits: credits,
        used_credits: 0,
        credit_reset_date: expires_in.from_now
      )

      user.credit_transactions.create!(
        feature_name: "Plan Activation (#{plan.upcase})",
        credits_used: credits,
        balance_before: 0,
        balance_after: credits,
        action: "add",
        reference_id: "activation_#{id}"
      )
    end
  end

  private

  def set_amount
    self.amount_paise ||= self.class.plan_amount(plan, metadata["billing_cycle"] || "monthly") if plan.present?
  end
end
