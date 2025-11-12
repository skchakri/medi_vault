# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :credential, null: true, foreign_key: true
      t.integer :channel, null: false
      t.integer :alert_offset_days
      t.datetime :sent_at
      t.integer :status, default: 0, null: false
      t.text :error_text
      t.text :content

      t.timestamps
    end

    add_index :notifications, :channel
    add_index :notifications, :status
    add_index :notifications, [:user_id, :status]
    add_index :notifications, :sent_at
  end
end
