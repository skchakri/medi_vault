class CreateShortUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :short_urls do |t|
      t.string :token, null: false
      t.text :original_url, null: false
      t.integer :click_count, default: 0, null: false

      t.timestamps
    end
    add_index :short_urls, :token, unique: true
  end
end
