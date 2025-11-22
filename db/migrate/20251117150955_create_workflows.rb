# frozen_string_literal: true

class CreateWorkflows < ActiveRecord::Migration[7.1]
  def change
    create_table :workflows do |t|
      t.string :name, null: false
      t.text :description
      t.jsonb :nodes, null: false, default: []
      t.jsonb :edges, null: false, default: []
      t.string :status, null: false, default: 'draft'
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :workflows, :status
    add_index :workflows, :name
  end
end
