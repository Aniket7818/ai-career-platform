class AddSpamStrikesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :password_reset_strikes, :integer, default: 0
  end
end
