class CreateTagsAndCredentialTags < ActiveRecord::Migration[8.0]
  def change
    # Create tags table
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, default: '#6B7280'
      t.text :description
      t.boolean :is_default, default: false
      t.boolean :active, default: true
      t.references :user, foreign_key: true
      t.integer :usage_count, default: 0

      t.timestamps
    end

    # Create credential_tags join table
    create_table :credential_tags do |t|
      t.references :credential, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    # Add tags counter cache to credentials
    add_column :credentials, :tags_count, :integer, default: 0

    # Add indexes for performance
    add_index :tags, :name, unique: true
    add_index :tags, :is_default
    add_index :tags, :active
    add_index :tags, :usage_count
    add_index :tags, "LOWER(name)", name: 'index_tags_on_lower_name'
    add_index :credential_tags, [:credential_id, :tag_id], unique: true
  end
end
