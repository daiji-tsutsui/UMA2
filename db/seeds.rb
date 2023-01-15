# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

COURSE_ID_SAPPORO  = 1
COURSE_ID_NAKAYAMA = 4
RACE_CLASS_ID_G1     = 1
RACE_CLASS_ID_G2     = 2

if %w[development test].include? Rails.env
  RaceDate.find_or_create_by(value: '2022/10/22')
  Race.create([
    {
      name:          'Test1',
      race_date_id:  RaceDate.first.id,
      course_id:     COURSE_ID_SAPPORO,
      number:        11,
      race_class_id: RACE_CLASS_ID_G1,
      weather:       'Sunny',
    },
    {
      name:          'Test2',
      race_date_id:  RaceDate.first.id,
      course_id:     COURSE_ID_NAKAYAMA,
      number:        3,
      race_class_id: RACE_CLASS_ID_G2,
      weather:       'Rainy',
    },
  ])
end
