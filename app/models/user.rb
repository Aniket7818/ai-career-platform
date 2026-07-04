class User < ApplicationRecord
  ROLES = %w[user admin super_admin].freeze
  STATUSES = %w[active suspended].freeze
  SUBSCRIPTION_PLANS = %w[free plus pro team].freeze

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_many :resumes, dependent: :destroy
  has_many :feature_interests, dependent: :destroy
  has_many :audit_logs, dependent: :nullify
  has_many :payment_orders, dependent: :destroy
  has_many :billing_histories, dependent: :destroy
  has_many :credit_transactions, dependent: :destroy
  has_many :login_sessions, dependent: :destroy
  has_many :email_verification_logs, dependent: :destroy
  has_many :ai_logs, dependent: :destroy

  validates :role, inclusion: { in: ROLES }
  validates :status, inclusion: { in: STATUSES }
  validates :subscription_plan, inclusion: { in: SUBSCRIPTION_PLANS }

  validates :first_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: I18n.t("api.errors.username_format") }
  validates :last_name, length: { maximum: 100 }, allow_blank: true

  def self.find_for_database_authentication(warden_conditions)
    login = warden_conditions[:login] || warden_conditions[:email]
    return nil if login.blank?

    normalized = login.to_s.strip.downcase
    find_by(email: normalized) || find_by("LOWER(username) = ?", normalized)
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ")
  end

  def super_admin?
    role == "super_admin"
  end

  def verified?
    confirmed_at.present? || verified_at.present?
  end

  def send_on_create_confirmation_instructions
    false
  end

  def paid_plan?
    subscription_plan.in?(%w[plus pro team]) && subscription_expires_at.present? && subscription_expires_at.future?
  end

  def free_downloads_remaining
    return Float::INFINITY if paid_plan?

    [3 - resume_downloads_count, 0].max
  end

  def subscription_seconds_remaining
    return 0 unless paid_plan?

    [subscription_expires_at - Time.current, 0].max.to_i
  end

  def active_for_authentication?
    status != "suspended"
  end

  def inactive_message
    status == "suspended" ? :suspended : :inactive
  end

  before_create :initialize_welcome_credits

  # Safe credit accessors that treat nil as 0
  def safe_remaining_credits
    remaining_credits.to_i
  end

  def safe_used_credits
    used_credits.to_i
  end

  private

  def initialize_welcome_credits
    self.monthly_credit_limit ||= 50
    self.remaining_credits    ||= 50
    self.used_credits         ||= 0
  end
end
