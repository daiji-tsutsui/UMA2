# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  before_action :make_caches, only: %i[index show]

  def index
    TestJob.perform_later('This is a test.')
    @races = Race.all.map { |race| format(race) }
  end

  def show
    @race = format(Race.find_by(id: params[:id]))
  end

  private

  def format(record)
    return format_for_nil if record.nil?

    {
      name:    record.name,
      date:    get_date_or_failover(record.race_date_id),
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

  def get_date_or_failover(date_id)
    @dates = {} if @dates.nil?
    return @dates[date_id] if @dates.key?(date_id)

    @dates[date_id] = RaceDate.find(date_id).value
  end
end
