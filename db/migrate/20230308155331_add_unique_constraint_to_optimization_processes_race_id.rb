class AddUniqueConstraintToOptimizationProcessesRaceId < ActiveRecord::Migration[7.0]
  def change
    remove_index :optimization_processes, :race_id if index_exists?(:optimization_processes, :race_id)
    add_index :optimization_processes, :race_id, unique: true
  end
end
