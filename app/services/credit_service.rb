class CreditService
  class InsufficientCreditsError < StandardError; end

  # Default credit costs for various AI features
  FEATURE_COSTS = {
    interview_answer: 1,
    ats_analysis: 2,
    cover_letter: 4,
    resume_rewrite: 5,
    linkedin_review: 5,
    resume_analysis: 3,
    mock_interview: 20
  }.freeze

  def self.consume!(user, feature_key, reference_id: nil)
    cost = FEATURE_COSTS[feature_key.to_sym]
    raise ArgumentError, "Unknown feature: #{feature_key}" if cost.nil?

    if user.remaining_credits.to_i < cost
      raise InsufficientCreditsError, "Required #{cost} credits, but user only has #{user.remaining_credits.to_i}."
    end

    User.transaction do
      balance_before = user.remaining_credits.to_i
      balance_after = balance_before - cost

      user.update!(
        remaining_credits: balance_after,
        used_credits: user.used_credits.to_i + cost
      )

      user.credit_transactions.create!(
        feature_name: feature_key.to_s.titleize,
        credits_used: cost,
        balance_before: balance_before,
        balance_after: balance_after,
        action: "deduct",
        reference_id: reference_id
      )
    end
  end

  def self.add_credits!(user, amount, feature_name: "Manual Adjustment", reference_id: nil)
    User.transaction do
      balance_before = user.remaining_credits.to_i
      balance_after = balance_before + amount

      user.update!(
        remaining_credits: balance_after,
        monthly_credit_limit: [ user.monthly_credit_limit.to_i, balance_after ].max
      )

      user.credit_transactions.create!(
        feature_name: feature_name,
        credits_used: amount,
        balance_before: balance_before,
        balance_after: balance_after,
        action: "add",
        reference_id: reference_id
      )
    end
  end
end
