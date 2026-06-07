class CreateAdminSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :admin_settings do |t|
      t.string :key, null: false
      t.jsonb :value, null: false, default: {}

      t.timestamps
    end

    add_index :admin_settings, :key, unique: true
  end
end
