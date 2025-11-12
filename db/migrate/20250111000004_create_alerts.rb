# frozen_string_literal: true

class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.references :credential, null: false, foreign_key: true
      t.integer :offset_days, null: false
      t.date :alert_date, null: false
      t.integer :status, default: 0, null: false
      t.datetime :sent_at
      t.text :message

      t.timestamps
    end

    add_index :alerts, :alert_date
    add_index :alerts, :status
    add_index :alerts, [:credential_id, :offset_days], unique: true
  end
end
