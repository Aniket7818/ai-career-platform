class AddObservabilityToAiLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :ai_logs, :raw_request_json, :jsonb
    add_column :ai_logs, :raw_response_json, :jsonb
    add_column :ai_logs, :performance_events, :jsonb
    add_column :ai_logs, :provider_headers, :jsonb
    add_column :ai_logs, :provider_request_id, :string
    add_column :ai_logs, :finish_reason, :string
    add_column :ai_logs, :http_status, :integer
  end
end
