class AddSmsTemplateFieldsToEmailTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :email_templates, :sms_body, :text
  end
end
