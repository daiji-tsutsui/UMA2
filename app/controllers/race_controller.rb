# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  before_action :make_caches, only: %i[index show]

  def index
    records = Race.where.associated(:race_date)
                  .select('races.*, race_dates.value')
                  .all
    @races = records.map { |race| format(race) }
  end

  def show
    record = Race.where.associated(:race_date)
                 .select('races.*, race_dates.value')
                 .find_by(id: params[:id])
    @race = format(record)
  end

  private

  def format(record)
    return format_for_nil if record.nil?

    {
      name:    record.name,
      date:    record.value,
      course:  @courses[record.course_id],
      number:  record.number,
      class:   @classes[record.race_class_id],
      weather: record.weather,
    }
  end

  def format_for_nil
    %i[name date course number class weather].to_h { |col| [col, 'No Data'] }
  end

  def make_caches
    return unless @courses.nil? || @classes.nil?

    @courses = Course.all.to_h { |course| [course.id, course.name] }
    @classes = RaceClass.all.to_h { |elem| [elem.id, elem.name] }
  end
end
