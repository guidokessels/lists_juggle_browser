class Ship < ApplicationRecord
  include Concerns::DirectQuery

  has_many :pilots
  has_many :factions, through: :pilots

  has_and_belongs_to_many :ship_combos

  validates :xws, uniqueness: true

  scope :small, -> { where(size: 'small') }
  scope :large, -> { where(size: 'large') }
  scope :huge, -> { where(size: 'huge') }
  scope :for_faction_xws, ->(xws) { joins(:factions).merge(Faction.where(xws: xws)).uniq }

end
