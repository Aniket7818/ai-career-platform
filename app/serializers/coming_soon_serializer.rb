class ComingSoonSerializer
  def initialize(interest_counts:, user_interests: [], trend_data: {})
    @interest_counts = interest_counts
    @user_interests = user_interests
    @trend_data = trend_data
  end

  def as_json(*)
    {
      stats: {
        total_interests: @interest_counts.values.sum,
        features_in_development: UpcomingFeatures::DEFINITIONS.count { |f| f[:status] == FeatureStatus::IN_DEVELOPMENT },
        features_launching_soon: UpcomingFeatures::DEFINITIONS.count { |f| f[:status] == FeatureStatus::LAUNCHING_SOON },
        average_progress: average_progress
      },
      features: UpcomingFeatures::DEFINITIONS.map { |feature| serialize_feature(feature) },
      trend: @trend_data,
      user_interests: @user_interests
    }
  end

  private

  def serialize_feature(feature)
    key = feature[:key]
    {
      key: key,
      status: feature[:status],
      progress: feature[:progress],
      estimated_availability: feature[:estimated_availability],
      interest_count: @interest_counts[key] || 0,
      notified: @user_interests.include?(key)
    }
  end

  def average_progress
    total = UpcomingFeatures::DEFINITIONS.sum { |f| f[:progress] }
    (total.to_f / UpcomingFeatures::DEFINITIONS.size).round
  end
end
