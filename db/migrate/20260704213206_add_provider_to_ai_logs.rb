class AddProviderToAiLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :ai_logs, :provider, :string
  end
end
