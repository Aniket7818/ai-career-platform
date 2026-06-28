class CreditResetService
  def self.process_all!
    # Find all users with active paid plans whose credit_reset_date is past due or today
    User.where.not(subscription_plan: 'free')
        .where('credit_reset_date <= ?', Time.current)
        .find_each do |user|
      new.reset_credits!(user)
    end
  end

  def reset_credits!(user)
    return unless user.paid_plan?
    
    # Prevent duplicate resets by checking if the reset date is in the future
    return if user.credit_reset_date.present? && user.credit_reset_date > Time.current

    ActiveRecord::Base.transaction do
      # Calculate new reset date (1 month from current reset date or from now)
      new_reset_date = calculate_next_reset_date(user)
      
      # Determine monthly limit based on plan
      monthly_limit = plan_limit(user.subscription_plan)
      
      # Log the transaction before changing balances
      user.credit_transactions.create!(
        feature_name: 'Monthly Credits Reset',
        credits_used: monthly_limit - user.remaining_credits.to_i,
        balance_before: user.remaining_credits.to_i,
        balance_after: monthly_limit,
        action: 'add',
        reference_id: "reset_#{Time.current.strftime('%Y%m%d')}"
      )

      # Update the user record
      user.update!(
        monthly_credit_limit: monthly_limit,
        remaining_credits: monthly_limit,
        used_credits: 0,
        credit_reset_date: new_reset_date
      )

      # Send transactional email asynchronously
      SubscriptionMailer.with(user: user).credit_reset.deliver_later
    end
  rescue => e
    Rails.logger.error "Failed to reset credits for User #{user.id}: #{e.message}"
  end

  private

  def calculate_next_reset_date(user)
    base_date = user.credit_reset_date || Time.current
    # Fast forward the date if it's way in the past (e.g. system was down)
    base_date = Time.current if base_date < 1.month.ago
    base_date + 1.month
  end

  def plan_limit(plan)
    case plan
    when 'plus' then 150
    when 'pro' then 500
    when 'team' then 1000
    else 10
    end
  end
end
