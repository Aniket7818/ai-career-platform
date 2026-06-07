class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :user, optional: true

  validates :action, presence: true
end
