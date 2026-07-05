class CreateAiLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true
      t.string :feature
      t.string :prompt_version
      t.string :fingerprint
      t.integer :credits_used
      t.integer :tokens_in
      t.integer :tokens_out
      t.decimal :estimated_cost, precision: 10, scale: 6
      t.string :model
      t.integer :response_time
      t.string :status
      t.text :error_message
      t.text :request_prompt
      t.text :response_content

      t.timestamps
    end
  end
end
