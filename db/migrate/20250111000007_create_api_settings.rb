# frozen_string_literal: true

class CreateApiSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :api_settings do |t|
      t.string :key, null: false
      t.string :value
      t.string :encrypted_value
      t.string :encrypted_value_iv
      t.boolean :enabled, default: true
      t.string :description

      t.timestamps
    end

    add_index :api_settings, :key, unique: true
    add_index :api_settings, :enabled
  end
end
