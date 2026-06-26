class PaymentOrder < ApplicationRecord
  PLANS = {
    "plus" => { monthly_paise: 9900, yearly_paise: 99900, label: "CareerAI Plus" },
    "pro" => { monthly_paise: 19900, yearly_paise: 199900, label: "CareerAI Pro" },
    "team" => { monthly_paise: 49900, yearly_paise: 49900, label: "Team (Legacy)" }
  }.freeze

  belongs_to :user

  validates :plan, inclusion: { in: PLANS.keys }
  validates :status, inclusion: { in: %w[created paid failed] }
  validates :amount_paise, numericality: { greater_than: 0 }

  before_validation :set_amount, on: :create

  def self.plan_amount(plan, billing_cycle)
    plan_config = PLANS.fetch(plan.to_s)
    billing_cycle == "yearly" ? plan_config[:yearly_paise] : plan_config[:monthly_paise]
  end

  def activate!
    transaction do
      update!(status: "paid", activated_at: Time.current)
      cycle = metadata["billing_cycle"] || "monthly"
      expires_in = cycle == "yearly" ? 1.year : 1.month
      user.update!(
        subscription_plan: plan,
        subscription_started_at: Time.current,
        subscription_expires_at: expires_in.from_now,
        razorpay_subscription_id: razorpay_order_id
      )
    end
  end

  private

  def set_amount
    self.amount_paise ||= self.class.plan_amount(plan, metadata["billing_cycle"] || "monthly") if plan.present?
  end
end
