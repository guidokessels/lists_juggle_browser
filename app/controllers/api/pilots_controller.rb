class Api::PilotsController < ApplicationController

  def index
    ship = get_ship(params[:ship_id])
    factions = get_factions(params[:faction_id])
    pilots_for_ship_and_factions = Pilot.where ship_id: ship[:id], faction_id: factions
    pilots = pilots_for_ship_and_factions.map do |pilot| pilot.xws end
    render json: pilots
  end

  def show
    factions = get_factions(params[:faction_id])
    ship = get_ship(params[:ship_id])
    pilot = get_pilot(params[:id], ship, factions)
    render json: {
        pilot: pilot,
        upgrades: get_upgrades(pilot[:id], 5),
        ship_combos: get_ship_combos(pilot[:id], 5),
    }
  end

  private

  def get_pilot(xws, ship, factions)
    pilot = Pilot.find_by ship_id: ship[:id], xws: xws, faction_id: factions
    if pilot == nil
      raise "Error: Could not find pilot for xws=#{xws}"
    end
    {
        id: pilot.id,
        name: pilot.name,
        xws: pilot.xws,
    }
  end

  def get_ship(xws)
    ship = Ship.find_by xws: xws
    if ship == nil
      raise "Error: Unknown ship, xws=#{xws}"
    end
    {
        id: ship.id,
        name: ship.name,
        xws: ship.xws,
    }
  end

  def get_factions(xws)
    Faction.where xws: xws
  end

  def get_upgrades(pilot, limit)
    upgrades = Rankers::UpgradesRanker.new(ranking_configuration, pilot_id: pilot, limit: limit).upgrades
    upgrades.map do |upgrade|
      {
        id: upgrade.id,
        name: upgrade.name,
        type: upgrade.upgrade_type,
        xws: upgrade.xws
      }
    end
  end

  def get_ship_combos(pilot, limit)
    ship_combos_ranker = Rankers::ShipCombosRanker.new(ranking_configuration, pilot_id: pilot, limit: limit)
    ship_combos_ranker.ship_combos.map { |ship_combo|
      squadrons = Rankers::SquadronsRanker.new(ranking_configuration, ship_combo_id: ship_combo.id, limit: 2).squadrons
      {
          id: ship_combo.id,
          archetype_name: ship_combo.archetype_name,
          ships: ship_combos_ranker.ships[ship_combo.id].map do |ship|
            {
                id: ship[:id],
                name: ship[:name],
                xws: ship[:xws],
            }
          end,
          squadrons: squadrons.map do |s|
            {
                xws: s.xws,
            }
          end
      }
    }
  end

end
