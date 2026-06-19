class PaymentOrder < ApplicationRecord
  PLANS = {
    "pro" => { amount_paise: 9900, label: "Pro" },
    "team" => { amount_paise: 19900, label: "Team" }
  }.freeze

  belongs_to :user

  validates :plan, inclusion: { in: PLANS.keys }
  validates :status, inclusion: { in: %w[created paid failed] }
  validates :amount_paise, numericality: { greater_than: 0 }

  before_validation :set_amount, on: :create

  def self.plan_amount(plan)
    PLANS.fetch(plan.to_s).fetch(:amount_paise)
  end

  def activate!
    transaction do
      update!(status: "paid", activated_at: Time.current)
      user.update!(
        subscription_plan: plan,
        subscription_started_at: Time.current,
        subscription_expires_at: 1.month.from_now,
        razorpay_subscription_id: razorpay_order_id
      )
    end
  end

  private

  def set_amount
    self.amount_paise ||= self.class.plan_amount(plan) if plan.present?
  end
end
