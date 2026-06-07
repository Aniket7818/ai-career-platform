class CreateFeatureInterests < ActiveRecord::Migration[7.2]
  def change
    create_table :feature_interests do |t|
      t.string :feature_key, null: false
      t.references :user, null: true, foreign_key: true
      t.string :email

      t.timestamps
    end

    add_index :feature_interests, :feature_key
    add_index :feature_interests, %i[user_id feature_key], unique: true, where: "user_id IS NOT NULL"
    add_index :feature_interests, %i[email feature_key], unique: true, where: "email IS NOT NULL"
  end
end
