class AddCreditsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :monthly_credit_limit, :integer
    add_column :users, :remaining_credits, :integer
    add_column :users, :used_credits, :integer
    add_column :users, :credit_reset_date, :datetime
  end
end
