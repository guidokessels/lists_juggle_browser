class Api::ShipsController < ApplicationController

  def index
    ships_for_faction = Ship.for_faction_xws params[:faction_id]
    ships = ships_for_faction.map do |ship| ship.xws end
    render json: ships
  end

end
