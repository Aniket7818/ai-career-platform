class Resume < ApplicationRecord
  belongs_to :user
  has_many :resume_versions, dependent: :destroy
  has_many :ai_logs, dependent: :destroy

  STATUSES = %w[draft published archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults

  # ─── Scopes ─────────────────────────────────────────────────────────────────
  scope :with_current_version, -> { includes(:resume_versions) }

  # ─── Helpers ─────────────────────────────────────────────────────────────────

  # Returns the single version marked as current for this resume.
  # There should always be exactly one; if none exists (legacy resumes), returns nil.
  def current_version
    resume_versions.find_by(is_current: true)
  end

  # Returns the highest version_number recorded for this resume.
  def latest_version_number
    resume_versions.maximum(:version_number) || 0
  end

  private

  def set_defaults
    self.status      ||= "draft"
    self.template_id ||= "modern"
    self.content     ||= {}
  end
end
