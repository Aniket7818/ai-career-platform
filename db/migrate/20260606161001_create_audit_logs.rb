class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :actor, foreign_key: { to_table: :users }
      t.references :user, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.text :details

      t.timestamps
    end

    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
