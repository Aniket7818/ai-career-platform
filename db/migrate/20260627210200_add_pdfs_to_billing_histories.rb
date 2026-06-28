class AddPdfsToBillingHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :billing_histories, :invoice_pdf_path, :string
    add_column :billing_histories, :receipt_pdf_path, :string
  end
end
