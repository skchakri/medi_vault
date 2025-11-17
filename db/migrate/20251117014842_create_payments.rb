class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: 'usd'
      t.integer :status, null: false, default: 0
      t.text :description
      t.datetime :paid_at
      t.text :receipt_url

      t.timestamps
    end

    add_index :payments, :stripe_payment_intent_id, unique: true
    add_index :payments, [:user_id, :paid_at]
    add_index :payments, :status
  end
end
