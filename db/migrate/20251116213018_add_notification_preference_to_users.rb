class AddNotificationPreferenceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notification_preference, :integer, default: 0, null: false
  end
end
