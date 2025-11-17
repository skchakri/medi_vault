class AddPaymentFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :payment_method_last4, :string
    add_column :users, :payment_method_brand, :string
    add_column :users, :payment_method_expires_at, :date
  end
end
