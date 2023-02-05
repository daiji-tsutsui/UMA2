class CreateScheduleRules < ActiveRecord::Migration[7.0]
  def change
    create_table :schedule_rules do |t|
      t.integer    :disable,   null: false, default: 0
      t.text       :data_json, null: false
      t.timestamps
    end
  end
end
