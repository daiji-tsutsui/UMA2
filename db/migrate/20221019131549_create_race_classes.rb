class CreateRaceClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :race_classes do |t|
      t.text :name, null: false
      t.timestamps
    end
    add_index :race_classes, :name, unique: true
  end
end
