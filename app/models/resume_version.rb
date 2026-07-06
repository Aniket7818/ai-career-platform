# ResumeVersion stores a complete, immutable snapshot of a resume's content
# at a specific point in time. This is NOT destructive — old versions are
# preserved forever for rollback, auditing, and score timeline visualization.
#
# Sources:
#   "manual"       — Auto-created when the user explicitly saves or the content
#                    drifts significantly from the last version.
#   "optimization" — Created automatically before optimization suggestions are applied.
#   "tailoring"    — Created when a tailored version is generated for a job posting.
#   "restore"      — Created when the user restores a previous version (non-destructive).
#
# Version numbers are scoped per resume and increment sequentially (1, 2, 3…).
# Exactly ONE version per resume has is_current = true at any given time.
class ResumeVersion < ApplicationRecord
  # ─── Associations ───────────────────────────────────────────────────────────
  belongs_to :resume
  belongs_to :user

  # Optional FK for future phases — populated when a version is created by
  # an optimization analysis or a job-match tailoring session.
  # These columns don't exist yet; they will be added in Phase 3.3 / 3.6.
  # belongs_to :resume_analysis, optional: true
  # belongs_to :job_match, optional: true

  # ─── Constants ──────────────────────────────────────────────────────────────
  SOURCES = %w[manual optimization tailoring restore].freeze

  # ─── Validations ────────────────────────────────────────────────────────────
  validates :label,            presence: true
  validates :content_snapshot, presence: true
  validates :source,           inclusion: { in: SOURCES }
  validates :version_number,   presence: true,
                               numericality: { only_integer: true, greater_than: 0 },
                               uniqueness: { scope: :resume_id }

  # ─── Scopes ─────────────────────────────────────────────────────────────────
  scope :chronological,  -> { order(version_number: :asc) }
  scope :reverse_chrono, -> { order(version_number: :desc) }
  scope :current,        -> { where(is_current: true) }
  scope :by_source,      ->(src) { where(source: src) }
  scope :for_resume,     ->(r)   { where(resume: r) }

  # ─── Serialization helpers ───────────────────────────────────────────────────

  # Returns a summary hash safe for the public API.
  def api_json
    {
      id:               id,
      resume_id:        resume_id,
      version_number:   version_number,
      label:            label,
      source:           source,
      is_current:       is_current,
      change_summary:   change_summary,
      score_at_creation: score_at_creation,
      created_at:       created_at,
      updated_at:       updated_at
    }
  end

  # Returns the full content snapshot — used when the user previews or
  # restores a version.
  def api_json_with_content
    api_json.merge(content_snapshot: content_snapshot)
  end
end
