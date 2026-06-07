class LoginSession < ApplicationRecord
  belongs_to :user

  validates :logged_in_at, presence: true
end
