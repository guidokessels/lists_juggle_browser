class ApiPilotController < ApplicationController

  def index
    @view = Rankers::ShipCombosRanker.new(ranking_configuration, limit: 120)
  end

  def show
    pilot = pilot(params[:id])
    render json: {
        pilot: pilot,
        ship: ship(pilot[:ship_id]),
        upgrades: upgrades_for_pilot(pilot[:id], 5),
        ship_combos: ship_combos_for_pilot(pilot[:id], 5)
    }
  end

  private

  def ship_combos_for_pilot(pilot, limit)
    ship_combos_ranker = Rankers::ShipCombosRanker.new(ranking_configuration, pilot_id: pilot, limit: limit)
    ship_combos_ranker.ship_combos.map { |ship_combo|
      squadrons = Rankers::SquadronsRanker.new(ranking_configuration, ship_combo_id: ship_combo.id, limit: 2).squadrons
      {
          id: ship_combo.id,
          archetype_name: ship_combo.archetype_name,
          ships: ship_combos_ranker.ships[ship_combo.id],
          squadrons: squadrons.map { |s| {
              xws: s.xws
          } }
      }
    }
  end

  def pilot(id)
    pilot = Pilot.find(id)
    {
        id: pilot.id,
        name: pilot.name,
        xws: pilot.xws,
        ship_id: pilot.ship_id,
        faction: pilot.faction.name
    }
  end

  def ship(id)
    ship = Ship.find(id)
    {
        id: ship.id,
        name: ship.name,
        xws: ship.xws
    }
  end

  def upgrades_for_pilot(pilot, limit)
    upgrades = Rankers::UpgradesRanker.new(ranking_configuration, pilot_id: pilot, limit: limit).upgrades
    upgrades.map { |u| {
        id: u.id,
        name: u.name,
        type: u.upgrade_type,
        xws: u.xws
    } }
  end

end
