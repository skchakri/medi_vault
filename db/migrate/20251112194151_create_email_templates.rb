class CreateEmailTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :email_templates do |t|
      t.string :name, null: false
      t.string :template_type, null: false
      t.string :subject, null: false
      t.text :html_body, null: false
      t.text :text_body
      t.json :variables, default: {}, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :email_templates, [:template_type, :active]
    add_index :email_templates, :name, unique: true
  end
end
