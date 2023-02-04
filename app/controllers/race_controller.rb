# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  ERROR_MESSAGE_NO_SUCH_RACE = 'No such a race...'

  def index
    @races = Race.search(search_params)
                 .sort_by_date
                 .preload(:race_date, :race_class, :course)
                 .paginate(page: params[:page])
  end

  def show
    @race = Race.find_by(id: params[:id]) and return

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
    redirect_to races_path and return
  end

  private

  def search_params
    params.permit(:name, :date, :course, :number, race_class: [])
  end
end
