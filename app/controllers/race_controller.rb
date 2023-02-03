# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  ERROR_MESSAGE_NO_SUCH_RACE = 'No such a race...'

  def index
    @races = Race.all.preload(:race_date, :race_class, :course)
                 .order(race_date_id: :DESC)
                 .order(course_id: :ASC)
                 .order(number: :ASC)
                 .paginate(page: params[:page])
  end

  def show
    @race = Race.find_by(id: params[:id]) and return

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
    redirect_to races_path and return
  end
end
