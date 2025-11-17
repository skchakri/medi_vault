class CreateThemeSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :theme_settings do |t|
      t.string :primary_color, null: false, default: "#7E22CE"
      t.string :secondary_color, null: false, default: "#9333EA"
      t.string :font_family, null: false, default: "system"

      t.timestamps
    end

    # Create the initial singleton record
    reversible do |dir|
      dir.up do
        ThemeSetting.create!(
          primary_color: "#7E22CE",
          secondary_color: "#9333EA",
          font_family: "system"
        )
      end
    end
  end
end
