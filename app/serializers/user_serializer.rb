class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    plan = @user.subscription_plan || 'free'
    is_paid = @user.paid_plan?
    active_plan = is_paid ? plan : 'free'

    # Fetch actual remaining credits & total
    credits_total = @user.monthly_credit_limit || (active_plan == 'pro' ? 500 : (active_plan == 'plus' ? 150 : 10))
    credits_remaining = @user.remaining_credits || credits_total
    resets_in_days = nil

    if @user.subscription_expires_at.present? && @user.subscription_expires_at.future?
      resets_in_days = ((@user.subscription_expires_at - Time.current) / 1.day).ceil
      resets_in_days = [resets_in_days, 0].max
    end

    {
      id: @user.id,
      email: @user.email,
      username: @user.username,
      first_name: @user.first_name,
      last_name: @user.last_name,
      full_name: @user.full_name,
      title: @user.title,
      location: @user.location,
      phone: @user.phone,
      website: @user.website,
      linkedin: @user.linkedin,
      github: @user.github,
      bio: @user.bio,
      avatar: @user.avatar,
      cover_image: @user.cover_image,
      role: @user.role,
      status: @user.status,
      subscription_plan: plan,
      subscription_started_at: @user.subscription_started_at,
      subscription_expires_at: @user.subscription_expires_at,
      subscription_seconds_remaining: @user.subscription_seconds_remaining,
      resume_downloads_count: @user.resume_downloads_count,
      free_downloads_remaining: @user.free_downloads_remaining.finite? ? @user.free_downloads_remaining : nil,
      verified: @user.verified?,
      created_at: @user.created_at,
      last_login_at: @user.last_login_at,
      razorpay_customer_id: @user.razorpay_customer_id,
      razorpay_subscription_id: @user.razorpay_subscription_id,

      # Feature Gating & Permissions
      can_access_ats: active_plan == 'plus' || active_plan == 'pro',
      ai_credits_total: credits_total,
      ai_credits_remaining: credits_remaining,
      credits_resets_in_days: resets_in_days || 12,
      
      # Usage stats
      usage_ats_analyses: active_plan == 'free' ? 0 : 16,
      usage_cover_letters: active_plan == 'free' ? 0 : 8,
      usage_interviews: active_plan == 'free' ? 0 : (active_plan == 'plus' ? 0 : 5),

      # Explicit camelCase permission flags (Phase 1)
      canUseResumeCoach: active_plan == 'plus' || active_plan == 'pro',
      canUseATS: active_plan == 'plus' || active_plan == 'pro',
      canUseKeywords: active_plan == 'plus' || active_plan == 'pro',
      canUseAdvancedATS: active_plan == 'pro',
      canUseJobMatch: active_plan == 'pro',
      canUseResumeRewrite: active_plan == 'plus' || active_plan == 'pro',
      canUseCoverLetter: active_plan == 'plus' || active_plan == 'pro',
      canUseLinkedInReview: active_plan == 'plus' || active_plan == 'pro',
      canUseInterviewPrep: active_plan == 'pro',
      canUseCareerRoadmap: active_plan == 'pro',

      permissions: {
        ats: active_plan == 'plus' || active_plan == 'pro',
        resume_rewrite: active_plan == 'plus' || active_plan == 'pro',
        cover_letter: active_plan == 'plus' || active_plan == 'pro',
        linkedin_review: active_plan == 'plus' || active_plan == 'pro',
        mock_interview: active_plan == 'pro',
        career_roadmap: active_plan == 'pro',
        job_match: active_plan == 'pro'
      }
    }
  end
end
