# frozen_string_literal: true

# Horse information Controller
class HorseController < ApplicationController
  def index
    @horses = Horse.all.paginate(page: params[:page])
  end

  def show
    @horse = Horse.find_by(id: params[:id])
    # TODO race_horsesはViewではなくこっちでとった方がいい
    # ORDERとかできないので
  end
end
