class AddSubscriptionAndDownloadFields < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :subscription_started_at, :datetime
    add_column :users, :subscription_expires_at, :datetime
    add_column :users, :razorpay_customer_id, :string
    add_column :users, :razorpay_subscription_id, :string
    add_column :users, :resume_downloads_count, :integer, default: 0, null: false

    add_column :resumes, :downloaded_at, :datetime
    add_column :resumes, :download_count, :integer, default: 0, null: false

    add_index :users, :subscription_expires_at
    add_index :users, :razorpay_subscription_id
  end
end
