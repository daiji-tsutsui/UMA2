class AddLastRaceHorseIdToHorses < ActiveRecord::Migration[7.0]
  def change
    add_column :horses, :last_race_horse_id, :bigint
  end
end
