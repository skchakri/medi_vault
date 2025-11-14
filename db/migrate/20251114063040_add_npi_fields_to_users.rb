class AddNpiFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :title, :string
    add_column :users, :official_credentials, :string
    add_column :users, :npi_enumeration_type, :string
    add_column :users, :mailing_address, :jsonb
    add_column :users, :practice_address, :jsonb
    add_column :users, :location_address, :jsonb
    add_column :users, :npi_data, :jsonb
  end
end
