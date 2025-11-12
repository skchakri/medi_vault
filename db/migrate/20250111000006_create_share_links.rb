# frozen_string_literal: true

class CreateShareLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :share_links do |t|
      t.references :credential, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.boolean :one_time, default: true

      t.timestamps
    end

    add_index :share_links, :token, unique: true
    add_index :share_links, :expires_at
  end
end
