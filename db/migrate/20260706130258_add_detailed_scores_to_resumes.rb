class AddDetailedScoresToResumes < ActiveRecord::Migration[7.2]
  def change
    add_column :resumes, :ats_score, :integer
    add_column :resumes, :keyword_score, :integer
    add_column :resumes, :content_score, :integer
    add_column :resumes, :completeness_score, :integer
    add_column :resumes, :analysis_version, :integer
    add_column :resumes, :analysis_data, :jsonb, default: {}
  end
end
