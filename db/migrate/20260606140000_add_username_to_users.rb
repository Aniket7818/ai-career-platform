class AddUsernameToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :username, :string
    execute "UPDATE users SET username = 'user' || id WHERE username IS NULL"
    change_column_null :users, :last_name, true
    change_column_default :users, :last_name, from: "", to: nil
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
    change_column_null :users, :last_name, false, ""
    change_column_default :users, :last_name, from: nil, to: ""
  end
end
