class CreateRaceHorses < ActiveRecord::Migration[7.0]
  def change
    create_table :race_horses do |t|
      t.bigint  :race_id,  foreign_key: true
      t.bigint  :horse_id, foreign_key: true
      t.integer :frame
      t.integer :number
      t.string  :sexage
      t.string  :jockey
      t.string  :weight
      t.timestamps
    end
  end
end
