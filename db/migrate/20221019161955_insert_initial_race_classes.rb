# frozen_string_literal: true

class InsertInitialRaceClasses < ActiveRecord::Migration[7.0]
  def change
    classes = %w[G1 G2 G3 Others]
    classes.each do |cl|
      RaceClass.create(name: cl)
    end
  end
end
