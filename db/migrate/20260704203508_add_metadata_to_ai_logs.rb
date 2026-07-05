class AddMetadataToAiLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :ai_logs, :ip_address, :string
    add_column :ai_logs, :user_agent, :string
    add_column :ai_logs, :request_id, :string
  end
end
