class ScoreEvent < ApplicationRecord
  enum :event_type, {
    run: "run",
    four: "four",
    six: "six",
    wicket: "wicket",
    catch: "catch",
    run_out: "run_out",
    stumping: "stumping",
    maiden: "maiden",
    duck: "duck",
    milestone_50: "milestone_50",
    milestone_100: "milestone_100",
    economy_bonus: "economy_bonus",
    strike_rate_bonus: "strike_rate_bonus"
  }, validate: true

  belongs_to :match
  belongs_to :player

  validates :points, numericality: true
  validates :ball_number, uniqueness: { scope: [:match_id, :player_id, :event_type] }, allow_blank: true
end
