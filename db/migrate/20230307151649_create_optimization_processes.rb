class CreateOptimizationProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :optimization_processes do |t|
      t.references :race,        foreign_key: true, null: false
      t.text       :params_json
      t.bigint     :last_odds_history_id
      t.boolean    :is_finished, default: false, null: false
      t.timestamps
    end
  end
end
