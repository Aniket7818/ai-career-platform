class AddOptimizationFieldsToResumes < ActiveRecord::Migration[7.2]
  def change
    add_column :resumes, :target_role, :string
    add_column :resumes, :last_analysis_score, :integer
    add_column :resumes, :last_analyzed_at, :datetime
  end
end
