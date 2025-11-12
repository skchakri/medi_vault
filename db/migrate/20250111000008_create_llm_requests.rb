# frozen_string_literal: true

class CreateLlmRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_requests do |t|
      t.references :user, foreign_key: true
      t.integer :account_id
      t.integer :provider, null: false
      t.string :model
      t.integer :prompt_tokens
      t.integer :completion_tokens
      t.integer :total_tokens
      t.integer :cost_cents
      t.boolean :success, default: false
      t.text :error_text
      t.text :request_type

      t.timestamps
    end

    add_index :llm_requests, :provider
    add_index :llm_requests, :success
    add_index :llm_requests, :created_at
    add_index :llm_requests, [:user_id, :created_at]
  end
end
