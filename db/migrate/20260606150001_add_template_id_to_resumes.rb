class AddTemplateIdToResumes < ActiveRecord::Migration[7.2]
  def change
    add_column :resumes, :template_id, :string, default: "modern", null: false
  end
end
