class AddIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :race_horses, [:race_id, :horse_id], unique: true
    add_index :race_horses, :horse_id
  end
end
