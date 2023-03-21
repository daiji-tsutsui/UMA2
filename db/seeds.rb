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
COURSE_ID_KYOTO    = 8
RACE_CLASS_ID_G1 = 1
RACE_CLASS_ID_G2 = 2
RACE_CLASS_ID_G3 = 3

if %w[development test].include? Rails.env
  RaceDate.find_or_create_by(value: '2022/10/22')
  Race.create([
    {
      name:          'Test1', # has odds_history, but no optimization
      race_date_id:  RaceDate.first.id,
      course_id:     COURSE_ID_SAPPORO,
      number:        11,
      race_class_id: RACE_CLASS_ID_G1,
      weather:       'Sunny',
      distance:      2000,
      course_type:   '芝',
      starting_time: '15:45',
    },
    {
      name:          'Test2', # has neither odds_history and optimization
      race_date_id:  RaceDate.first.id,
      course_id:     COURSE_ID_NAKAYAMA,
      number:        3,
      race_class_id: RACE_CLASS_ID_G2,
      weather:       'Rainy',
      distance:      1000,
      course_type:   'ダ',
      starting_time: '11:10',
    },
    {
      name:          'Test3', # has both odds_history and optimization
      race_date_id:  RaceDate.first.id,
      course_id:     COURSE_ID_KYOTO,
      number:        8,
      race_class_id: RACE_CLASS_ID_G3,
      weather:       'Cloudy',
      distance:      1600,
      course_type:   '芝',
      starting_time: '14:10',
    },
  ])
  Horse.create([
    { name: 'ハリボテエレジー' },
    { name: 'アシタハレルカナ' },
    { name: 'タニノギムレット' },
    { name: 'ダイダバッター' },
  ])
  RaceHorse.create([
    {
      race_id:  1,
      horse_id: 1,
      frame:    1,
      number:   1,
      sexage:   '牡4',
      jockey:   'デムーロ',
    },
    {
      race_id:  1,
      horse_id: 2,
      frame:    2,
      number:   2,
      sexage:   'セ8',
      jockey:   '横山武',
    },
    {
      race_id:  1,
      horse_id: 3,
      frame:    3,
      number:   3,
      sexage:   'セ7',
      jockey:   '戸崎圭',
    },
    {
      race_id:  2,
      horse_id: 1,
      frame:    1,
      number:   1,
      sexage:   '牡5',
      jockey:   'デムーロ',
    },
    {
      race_id:  2,
      horse_id: 2,
      frame:    2,
      number:   2,
      sexage:   '牡7',
      jockey:   '武豊',
    },
    {
      race_id:  3,
      horse_id: 3,
      frame:    1,
      number:   1,
      sexage:   'セ7',
      jockey:   '戸崎圭',
    },
    {
      race_id:  3,
      horse_id: 4,
      frame:    2,
      number:   2,
      sexage:   '牝3',
      jockey:   '武豊',
    },
  ])
  Horse.find(1).update(last_race_horse_id: 4)
  Horse.find(2).update(last_race_horse_id: 5)
  Horse.find(3).update(last_race_horse_id: 6)
  Horse.find(4).update(last_race_horse_id: 7)
  ScheduleRule.create({
    disable:   1,
    data_json: '[{"duration":1000,"interval":100}]',
  })
  OddsHistory.create([
    {
      race_id:    1,
      data_json:  '[8.0,2.7,1.3]',
      created_at: '2023-02-11 14:15:30',
    },
    {
      race_id:    1,
      data_json:  '[16.0,5.3,1.1]',
      created_at: '2023-02-11 14:30:00',
    },
    {
      race_id:    3,
      data_json:  '[1.4,1.9]',
      created_at: '2023-03-21 13:50:00',
    },
    {
      race_id:    3,
      data_json:  '[1.2,2.4]',
      created_at: '2023-03-21 14:00:00',
    },
  ])
  OptimizationProcess.create({
    race_id:              3,
    params_json:          '{"a":[0.9,0.1],"b":[1.0,2.0],"t":[0.75,0.25]}',
    last_odds_history_id: 2,
  })
end
