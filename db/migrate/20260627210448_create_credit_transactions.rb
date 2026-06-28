class CreateCreditTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :credit_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :feature_name
      t.integer :credits_used
      t.integer :balance_before
      t.integer :balance_after
      t.string :action
      t.string :reference_id

      t.timestamps
    end
  end
end
