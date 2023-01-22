# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  before_action :load_static_record, only: %i[index show]

  ERROR_MESSAGE_NO_SUCH_RACE = 'No such a race...'

  def index
    @races = Race.where.associated(:race_date)
                 .select('races.*, race_dates.value AS date')
                 .all
  end

  def show
    @race = Race.where.associated(:race_date)
                .select('races.*, race_dates.value AS date')
                .find_by(id: params[:id])
    if @race.nil?
      flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
      redirect_to races_path and return
    end
  end

  private

  def load_static_record
    return unless @courses.nil? || @classes.nil?

    @courses = Course.all.to_h { |course| [course.id, course.name] }
    @classes = RaceClass.all.to_h { |elem| [elem.id, elem.name] }
  end
end
