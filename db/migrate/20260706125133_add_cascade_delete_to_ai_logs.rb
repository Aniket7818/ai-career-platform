class AddCascadeDeleteToAiLogs < ActiveRecord::Migration[7.2]
  def change
    # Remove existing non-cascade FK
    remove_foreign_key :ai_logs, :resumes

    # Re-add with CASCADE so deleting a resume also deletes its AI logs
    add_foreign_key :ai_logs, :resumes, on_delete: :cascade
  end
end
