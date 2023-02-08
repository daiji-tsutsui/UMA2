# frozen_string_literal: true

class CreateHorses < ActiveRecord::Migration[7.0]
  def change
    create_table :horses do |t|
      t.text :name, null: false
      t.timestamps
    end
    add_index :horses, :name, unique: true
  end
end
