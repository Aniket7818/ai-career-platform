class AiLog < ApplicationRecord
  belongs_to :user
  belongs_to :resume

  STATUSES = %w[success failed rejected].freeze

  validates :status, inclusion: { in: STATUSES }

  # Scopes for analytics and admin queries
  scope :successful,    -> { where(status: "success") }
  scope :failed,        -> { where(status: "failed") }
  scope :rejected,      -> { where(status: "rejected") }
  scope :by_feature,    ->(f) { where(feature: f) }
  scope :by_user,       ->(u) { where(user: u) }
  scope :recent,        -> { order(created_at: :desc) }

  # Rejection reasons for analytics
  REJECTION_REASONS = %w[
    cache_hit
    duplicate_request
    insufficient_credits
    rate_limited
    request_too_large
    invalid_input
    unauthorized
  ].freeze
end
