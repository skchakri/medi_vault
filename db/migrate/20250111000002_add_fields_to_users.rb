# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, null: false
    add_column :users, :npi, :string
    add_column :users, :npi_verified_at, :datetime
    add_column :users, :phone, :string
    add_column :users, :phone_verified, :boolean, default: false
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :plan, :integer, default: 0, null: false
    add_column :users, :plan_active, :boolean, default: false
    add_column :users, :notification_email, :boolean, default: true
    add_column :users, :notification_sms, :boolean, default: false
    add_column :users, :credentials_count, :integer, default: 0, null: false
    add_column :users, :trial_ends_at, :datetime
    add_column :users, :subscription_ends_at, :datetime

    add_index :users, :npi
    add_index :users, :role
    add_index :users, :plan
  end
end
