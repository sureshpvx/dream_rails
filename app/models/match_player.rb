class MatchPlayer < ApplicationRecord
  belongs_to :match
  belongs_to :player

  validates :player_id, uniqueness: { scope: :match_id }
  validates :fantasy_points, numericality: true

  delegate :name, :short_name, :role, :role_label, :team, :country, :base_price, to: :player
end
