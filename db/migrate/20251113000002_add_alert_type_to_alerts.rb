class AddAlertTypeToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_reference :alerts, :alert_type, foreign_key: true, null: true
    add_index :alerts, [:alert_type_id, :credential_id]
  end
end
