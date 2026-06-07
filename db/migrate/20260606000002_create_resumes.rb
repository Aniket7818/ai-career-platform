class CreateResumes < ActiveRecord::Migration[7.2]
  def change
    create_table :resumes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, null: false, default: "draft"
      t.jsonb :content, null: false, default: {}
      t.timestamps null: false
    end

    add_index :resumes, %i[user_id updated_at]
    add_index :resumes, :status
  end
end
