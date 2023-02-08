# frozen_string_literal: true

class AddColumnRaces < ActiveRecord::Migration[7.0]
  def change
    add_column :races, :distance, :integer
    add_column :races, :course_type, :string
    add_column :races, :starting_time, :string
  end
end
