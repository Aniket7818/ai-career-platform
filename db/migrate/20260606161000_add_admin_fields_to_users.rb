class AddAdminFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role, :string, null: false, default: "user"
    add_column :users, :status, :string, null: false, default: "active"
    add_column :users, :subscription_plan, :string, null: false, default: "free"
    add_column :users, :last_login_at, :datetime
    add_column :users, :verified_at, :datetime

    add_index :users, :role
    add_index :users, :status
    add_index :users, :subscription_plan
  end
end
