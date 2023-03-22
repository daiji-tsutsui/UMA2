class CreateRaceResults < ActiveRecord::Migration[7.0]
  def change
    create_table :race_results do |t|
      t.references :race, foreign_key: true, null: false
      t.text       :data_json,               null: false
      t.text       :odds_json,               null: false
      t.timestamps
    end
    remove_index :race_results, :race_id if index_exists?(:race_results, :race_id)
    add_index :race_results, :race_id, unique: true
  end
end
