# frozen_string_literal: true

# Horse information Controller
class HorseController < ApplicationController
  def index
    @horses = Horse.all
  end

  def show
    @horse = Horse.find_by(id: params[:id])
  end
end
