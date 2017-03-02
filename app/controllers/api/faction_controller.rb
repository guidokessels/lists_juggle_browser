class Api::FactionController < ApplicationController

  def index
    factions = Faction.all .map do |faction| faction.xws end .uniq
    render json: factions
  end

end
