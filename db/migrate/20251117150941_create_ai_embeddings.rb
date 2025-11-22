# frozen_string_literal: true

class CreateAiEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_embeddings do |t|
      t.string :provider, null: false
      t.string :model, null: false
      t.jsonb :vector, null: false, default: []
      t.integer :dim, null: false
      t.string :source_type
      t.bigint :source_id
      t.string :chunk_id
      t.jsonb :metadata, null: false, default: {}
      t.integer :cost_cents, null: false, default: 0

      t.timestamps
    end

    add_index :ai_embeddings, [:source_type, :source_id]
    add_index :ai_embeddings, :model
    add_index :ai_embeddings, :provider
  end
end
