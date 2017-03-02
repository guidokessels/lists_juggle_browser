class Api::UpgradesController < ApplicationController

  def index
    upgrades = Upgrade.all .map do |upgrade| upgrade.xws end
    render json: upgrades
  end

  def show
    upgrade = get_upgrade(params[:id])
    render json: {
        upgrade: upgrade,
        pilots: get_pilots(upgrade[:id], 5),
        ship_combos: get_ship_combos(upgrade[:id], 5),
    }
  end

  private

  def get_ship_combos(upgrade, limit)
    ship_combos_ranker = Rankers::ShipCombosRanker.new(ranking_configuration, upgrade_id: upgrade, limit: limit)
    ship_combos_ranker.ship_combos.map do |ship_combo|
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
          squadrons: squadrons.map do |squad|
            {
                xws: squad.xws,
            }
          end
      }
    end
  end

  def get_upgrade(xws)
    upgrade = Upgrade.find_by xws: xws
    {
        id: upgrade.id,
        xws: upgrade.xws,
        name: upgrade.name,
        type: upgrade.upgrade_type.name,
    }
  end

  def get_pilots(upgrade, limit)
    items = Rankers::PilotsRanker.new(ranking_configuration, upgrade_id: upgrade, limit: limit).pilots
    items.map do |item|
      {
          id: item.id,
          name: item.name,
          faction: item.faction,
          ship: item.ship_name,
          xws: item.xws,
      }
    end
  end

end
