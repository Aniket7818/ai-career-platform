class FeatureInterestSerializer
  def initialize(feature_interest, interest_count:)
    @feature_interest = feature_interest
    @interest_count = interest_count
  end

  def as_json(*)
    {
      feature_interest: {
        id: @feature_interest.id,
        feature_key: @feature_interest.feature_key,
        created_at: @feature_interest.created_at
      },
      interest_count: @interest_count
    }
  end
end
