class CreateAiOptimizationRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_optimization_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true
      t.string :action
      t.string :status
      t.jsonb :result
      t.text :error_message
      t.jsonb :payload
      t.jsonb :request_meta

      t.timestamps
    end
  end
end
