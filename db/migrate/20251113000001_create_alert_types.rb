class CreateAlertTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_types do |t|
      t.string :name, null: false
      t.integer :offset_days, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.jsonb :notification_channels, default: ['email'], null: false
      t.integer :priority, default: 0, null: false
      t.jsonb :user_plans, default: ['free', 'basic', 'pro'], null: false

      t.timestamps
    end

    add_index :alert_types, :name, unique: true
    add_index :alert_types, :active
    add_index :alert_types, :priority
  end
end
