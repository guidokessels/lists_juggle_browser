class ApiUpgradeController < ApplicationController

  def index
    @view = Rankers::ShipCombosRanker.new(ranking_configuration, limit: 120)
  end

  def show
    upgrade = upgrade(params[:id])
    render json: {
        upgrade: upgrade,
        pilots: pilots(upgrade[:id], 5),
        ship_combos: ship_combos(upgrade[:id], 5)
    }
  end

  private

  def ship_combos(upgrade, limit)
    ship_combos_ranker = Rankers::ShipCombosRanker.new(ranking_configuration, upgrade_id: upgrade, limit: limit)
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

  def upgrade(id)
    upgrade = Upgrade.find(id)
    {
        id: upgrade.id,
        name: upgrade.name,
        xws: upgrade.xws
    }
  end

  def pilots(upgrade, limit)
    items = Rankers::PilotsRanker.new(ranking_configuration, upgrade_id: upgrade, limit: limit).pilots
    items.map { |item| {
        id: item.id,
        name: item.name,
        xws: item.xws,
        faction: item.faction,
        ship_id: item.ship_id
    } }
  end

end
