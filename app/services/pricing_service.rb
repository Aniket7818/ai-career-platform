class PricingService
  PRICES = {
    production: {
      plus: { monthly: 199, yearly: 1999, label: "CareerAI Plus" },
      pro: { monthly: 499, yearly: 4999, label: "CareerAI Pro" }
    },
    testing: {
      plus: { monthly: 1, yearly: 2, label: "CareerAI Plus" },
      pro: { monthly: 3, yearly: 4, label: "CareerAI Pro" }
    }
  }.with_indifferent_access.freeze

  def self.test_mode_enabled?
    setting = AdminSetting.find_by(key: "developer_settings")
    return false if setting.nil?

    setting.value&.dig("payment_test_mode") == true
  end

  def self.current_mode
    test_mode_enabled? ? :testing : :production
  end

  def self.plans
    PRICES[current_mode]
  end

  def self.plan_price_in_rupees(plan, billing_cycle)
    plan_config = plans[plan.to_s]
    return 0 if plan_config.nil?

    billing_cycle == "yearly" ? plan_config[:yearly] : plan_config[:monthly]
  end

  def self.plan_price_in_paise(plan, billing_cycle)
    plan_price_in_rupees(plan, billing_cycle) * 100
  end
end
