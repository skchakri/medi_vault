class CreateMessageUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :message_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :message_type, null: false
      t.datetime :sent_at
      t.integer :status, null: false, default: 0
      t.integer :cost_cents, default: 0
      t.string :provider
      t.text :error_message

      t.timestamps
    end

    add_index :message_usages, [:user_id, :sent_at]
    add_index :message_usages, [:message_type, :sent_at]
    add_index :message_usages, :status
  end
end
