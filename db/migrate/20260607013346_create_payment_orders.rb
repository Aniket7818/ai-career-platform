class CreatePaymentOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan, null: false
      t.integer :amount_paise, null: false
      t.string :currency, default: "INR", null: false
      t.string :status, default: "created", null: false
      t.string :razorpay_order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature
      t.jsonb :metadata, default: {}, null: false
      t.datetime :activated_at

      t.timestamps
    end

    add_index :payment_orders, :status
    add_index :payment_orders, :razorpay_order_id, unique: true
  end
end
