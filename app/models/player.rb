class Player < ApplicationRecord
  enum :role, {
    batsman: "batsman",
    bowler: "bowler",
    all_rounder: "all_rounder",
    wicket_keeper: "wicket_keeper"
  }, validate: true

  enum :batting_style, {
    right_hand: "right_hand",
    left_hand: "left_hand"
  }, prefix: true, validate: { allow_nil: true }

  enum :bowling_style, {
    fast: "fast",
    medium: "medium",
    spin: "spin",
    leg_spin: "leg_spin"
  }, prefix: true, validate: { allow_nil: true }

  has_many :match_players, dependent: :destroy
  has_many :matches, through: :match_players
  has_many :score_events, dependent: :restrict_with_exception
  has_many :user_team_players, dependent: :restrict_with_exception

  validates :name, :short_name, :team, :country, presence: true
  validates :base_price, numericality: { greater_than: 0, less_than_or_equal_to: 20 }

  scope :active, -> { where(is_active: true) }

  def role_label
    {
      "batsman" => "BAT",
      "bowler" => "BOW",
      "all_rounder" => "AR",
      "wicket_keeper" => "WK"
    }.fetch(role)
  end
end
