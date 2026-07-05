class AddDetailsToAiLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :ai_logs, :cache_hit, :boolean
    add_column :ai_logs, :retry_count, :integer
    add_column :ai_logs, :failure_reason, :string
  end
end
