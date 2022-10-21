# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  def index
    @races = Race.all
  end

  def show
    base_data = Race.find(params[:id])
    @race = {
      name:    base_data.name,
      date:    RaceDate.find(base_data.race_date_id).value,
      course:  Course.find(base_data.course_id).name,
      number:  base_data.number,
      class:   RaceClass.find(base_data.race_class_id).name,
      weather: base_data.weather,
    }
  end
end
