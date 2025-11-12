# frozen_string_literal: true

class CreateCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.date :start_date
      t.date :end_date
      t.integer :status, default: 0, null: false
      t.string :source_filename
      t.jsonb :ai_extracted_json, default: {}
      t.boolean :ai_processed, default: false
      t.datetime :ai_processed_at
      t.text :notes

      t.timestamps
    end

    add_index :credentials, :status
    add_index :credentials, :end_date
    add_index :credentials, [:user_id, :end_date]
    add_index :credentials, :ai_processed
  end
end
