class CreateRaceDates < ActiveRecord::Migration[7.0]
  def change
    create_table :race_dates do |t|
      t.date :value, null: false
      t.timestamps
    end
    add_index :race_dates, :value, unique: true
  end
end
