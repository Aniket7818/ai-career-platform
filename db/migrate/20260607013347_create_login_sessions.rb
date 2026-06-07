class CreateLoginSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :login_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.string :session_id
      t.datetime :logged_in_at, null: false
      t.datetime :logged_out_at

      t.timestamps
    end

    add_index :login_sessions, :logged_in_at
    add_index :login_sessions, :ip_address
  end
end
