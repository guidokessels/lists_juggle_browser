module Rankers
  class PilotsRanker

    attr_reader :pilots, :number_of_tournaments, :number_of_squadrons

    def initialize(ranking_configuration, ship_id: nil, pilot_id: nil, limit: nil, ship_combo_id: nil, upgrade_id: nil)
      start_date      = ranking_configuration[:ranking_start]
      end_date        = ranking_configuration[:ranking_end]
      tournament_type = ranking_configuration[:tournament_type]
      joins           = <<-SQL
        inner join ships
          on ships.id = pilots.ship_id
        inner join factions
          on factions.id = pilots.faction_id
        inner join ship_configurations
          on ship_configurations.pilot_id = pilots.id
        inner join squadrons
          on ship_configurations.squadron_id = squadrons.id
        inner join tournaments
          on squadrons.tournament_id = tournaments.id
      SQL
      weight_query_builder = WeightQueryBuilder.new(ranking_configuration)
      attributes           = {
        id:                   'pilots.id',
        xws:                  'pilots.xws',
        name:                 'pilots.name',
        faction:              'factions.name',
        ship_id:              'ships.id',
        ship_name:            'ships.name',
        ship_font_icon_class: 'ships.font_icon_class',
        weight:               weight_query_builder.build_weight_query,
        squadrons:            'count(distinct squadrons.id)',
        tournaments:          'count(distinct tournaments.id)',
        average_percentile:   weight_query_builder.build_average_query,
        average_wlr:          weight_query_builder.build_win_loss_query,
      }
      pilot_relation       = Pilot
                               .joins(joins)
                               .group('pilots.id, pilots.name, factions.name, ships.id, ships.name')
                               .order('weight desc')
                               .where('tournaments.date >= ? and tournaments.date <= ?', start_date, end_date)
      if ship_id.present?
        pilot_relation = pilot_relation.where('ships.id = ?', ship_id)
      end
      if upgrade_id.present?
        upgrade_join = <<-SQL
          inner join ship_configurations_upgrades
            on ship_configurations_upgrades.ship_configuration_id = ship_configurations.id
        SQL
        pilot_relation = pilot_relation.joins(upgrade_join).where('ship_configurations_upgrades.upgrade_id = ?', upgrade_id)
      end
      if ship_combo_id.present?
        pilot_relation = pilot_relation.where('squadrons.ship_combo_id = ?', ship_combo_id)
      end
      if pilot_id.present?
        pilot_relation = pilot_relation.where('pilots.id = ?', pilot_id)
      end
      if limit.present?
        pilot_relation = pilot_relation.limit(limit)
      end
      if tournament_type.present?
        pilot_relation = pilot_relation.where('tournaments.tournament_type_id = ?', tournament_type)
      end
      @pilots = Pilot.fetch_query(pilot_relation, attributes)

      @number_of_tournaments, @number_of_squadrons = Rankers::GenericRanker.new(start_date, end_date, tournament_type).numbers
    end

  end
end
