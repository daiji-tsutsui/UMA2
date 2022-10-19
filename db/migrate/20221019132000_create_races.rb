# frozen_string_literal: true

class CreateRaces < ActiveRecord::Migration[7.0]
  def change
    create_table :races do |t|
      t.text       :name,       null: false
      t.references :race_date,  foreign_key: true
      t.references :course,     foreign_key: true
      t.integer    :number,     null: false
      t.references :race_class, foreign_key: true
      t.text       :weather
      t.timestamps
    end
  end
end
