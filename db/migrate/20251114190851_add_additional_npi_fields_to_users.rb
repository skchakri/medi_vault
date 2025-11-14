class AddAdditionalNpiFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :gender, :string
    add_column :users, :name_prefix, :string
    add_column :users, :name_suffix, :string
    add_column :users, :middle_name, :string
    add_column :users, :enumeration_date, :date
    add_column :users, :last_updated, :date
    add_column :users, :certification_date, :date
    add_column :users, :npi_status, :string
    add_column :users, :sole_proprietor, :boolean
    add_column :users, :organizational_subpart, :boolean
    add_column :users, :taxonomies, :jsonb
    add_column :users, :identifiers, :jsonb
  end
end
