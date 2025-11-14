class FixAlertsUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove the old unique index that doesn't include alert_type_id
    remove_index :alerts, name: "index_alerts_on_credential_id_and_offset_days"

    # Add new unique index that includes alert_type_id
    # This allows multiple alert types (email, SMS) for the same credential and offset
    add_index :alerts, [:credential_id, :offset_days, :alert_type_id],
              unique: true,
              name: "index_alerts_on_credential_offset_and_type"
  end
end
