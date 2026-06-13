class AddPasswordResetTrackingToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :reset_emails_sent_count, :integer, default: 0
    add_column :users, :last_reset_request_at, :datetime
  end
end
