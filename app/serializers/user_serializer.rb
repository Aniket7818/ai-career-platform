class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
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
      subscription_plan: @user.subscription_plan,
      subscription_started_at: @user.subscription_started_at,
      subscription_expires_at: @user.subscription_expires_at,
      subscription_seconds_remaining: @user.subscription_seconds_remaining,
      resume_downloads_count: @user.resume_downloads_count,
      free_downloads_remaining: @user.free_downloads_remaining.finite? ? @user.free_downloads_remaining : nil,
      verified: @user.verified?,
      created_at: @user.created_at,
      last_login_at: @user.last_login_at
    }
  end
end
