class AddFoeignKeysRaceHorses < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :race_horses, :races
    add_foreign_key :race_horses, :horses
  end
end
