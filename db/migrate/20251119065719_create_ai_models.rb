class CreateAiModels < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_models do |t|
      t.string :name, null: false
      t.string :provider, null: false
      t.string :model_identifier, null: false
      t.boolean :is_default, default: false, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :ai_models, :is_default
    add_index :ai_models, :active
  end
end
