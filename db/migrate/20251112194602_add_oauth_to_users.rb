class AddOauthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_expires_at, :datetime
    add_column :users, :avatar_url, :string

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :provider
  end
end
