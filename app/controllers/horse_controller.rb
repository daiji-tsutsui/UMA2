# frozen_string_literal: true

# Horse information Controller
class HorseController < ApplicationController
  ERROR_MESSAGE_NO_SUCH_HORSE = 'We do not know such a horse...'

  def index
    @horses = Horse.joins(:race_horse)
                   .search(search_params)
                   .sort_by_last_race
                   .includes(race_horse: { race: :race_date })
                   .paginate(page: params[:page])
  end

  def show
    @horse = Horse.find_by!(id: params[:id])
    @race_horses = @horse.race_horses
                         .order('race_id DESC')
                         .includes(race: %i[race_date race_class])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = ERROR_MESSAGE_NO_SUCH_HORSE
    redirect_to horses_path and return
  end

  private

  def search_params
    params.permit(:name, :date)
  end
end
