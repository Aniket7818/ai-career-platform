class Resume < ApplicationRecord
  belongs_to :user

  STATUSES = %w[draft published archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults

  private

  def set_defaults
    self.status ||= "draft"
    self.template_id ||= "modern"
    self.content ||= {}
  end
end
