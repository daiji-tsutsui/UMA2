# frozen_string_literal: true

class InsertNoneRaceClass < ActiveRecord::Migration[7.0]
  def change
    # 格付けのないレースは None
    # 海外レース等は Others
    RaceClass.create(name: 'None')
  end
end
