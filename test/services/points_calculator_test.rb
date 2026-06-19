require "test_helper"

class PointsCalculatorTest < ActiveSupport::TestCase
  test "calculates batting points with boundary milestone and strike-rate bonuses" do
    player = Player.create!(
      name: "Virat Kohli",
      short_name: "V. Kohli",
      role: "batsman",
      team: "RCB",
      country: "India",
      base_price: 10.5
    )
    match = Match.create!(
      team_a: "Royal Challengers Bengaluru",
      team_b: "Mumbai Indians",
      team_a_short: "RCB",
      team_b_short: "MI",
      match_date: 1.day.from_now,
      lock_time: 1.day.from_now - 15.minutes,
      venue: "M. Chinnaswamy Stadium",
      format: "T20"
    )
    match_player = MatchPlayer.create!(
      match: match,
      player: player,
      runs_scored: 72,
      balls_faced: 48,
      fours: 8,
      sixes: 2,
      strike_rate: 150.0
    )

    assert_equal BigDecimal("90.0"), PointsCalculator.new.match_player_points(match_player)
  end
end
