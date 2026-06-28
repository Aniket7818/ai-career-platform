class CreateBillingHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :billing_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan_name
      t.decimal :amount
      t.string :currency
      t.string :payment_provider
      t.string :payment_id
      t.string :order_id
      t.string :invoice_number
      t.string :billing_cycle
      t.string :payment_status
      t.datetime :paid_at
      t.datetime :renewal_date

      t.timestamps
    end
  end
end
