# frozen_string_literal: true

class CreateOddsHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :odds_histories do |t|
      t.references :race, foreign_key: true
      t.text       :data_json
      t.timestamps
    end
  end
end
