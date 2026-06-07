class FeatureInterest < ApplicationRecord
  belongs_to :user, optional: true

  validates :feature_key, presence: true, inclusion: { in: FeatureKeys::ALL }
  validates :feature_key, uniqueness: { scope: :user_id }, if: -> { user_id.present? }
  validates :feature_key, uniqueness: { scope: :email }, if: -> { email.present? }
  validates :email, presence: true, unless: :user_id?
  validate :user_or_email_present

  before_validation :normalize_email

  scope :for_feature, ->(key) { where(feature_key: key) }

  private

  def user_or_email_present
    return if user_id.present? || email.present?

    errors.add(:base, I18n.t("api.errors.feature_interest_identity_required"))
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
