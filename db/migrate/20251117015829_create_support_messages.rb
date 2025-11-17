class CreateSupportMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :support_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.boolean :is_admin_response, null: false, default: false
      t.integer :parent_id
      t.datetime :read_at

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :support_messages, :parent_id
    add_index :support_messages, [:user_id, :read_at]
    add_index :support_messages, :is_admin_response
    add_index :support_messages, [:user_id, :created_at]

    # Self-referential foreign key for threading
    add_foreign_key :support_messages, :support_messages, column: :parent_id
  end
end
