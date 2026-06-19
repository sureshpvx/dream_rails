require "test_helper"

class TeamValidatorTest < ActiveSupport::TestCase
  test "rejects more than seven players from one real team" do
    match = create_match
    players = []
    players << create_player("A WK", "wicket_keeper", "RCB")
    4.times { |index| players << create_player("A BAT #{index}", "batsman", "RCB") }
    players << create_player("A AR", "all_rounder", "RCB")
    2.times { |index| players << create_player("A BOW #{index}", "bowler", "RCB") }
    players << create_player("B AR", "all_rounder", "MI")
    2.times { |index| players << create_player("B BOW #{index}", "bowler", "MI") }
    players.each { |player| MatchPlayer.create!(match: match, player: player) }

    validator = TeamValidator.new(
      match: match,
      player_ids: players.map(&:id),
      captain_id: players.first.id,
      vice_captain_id: players.second.id
    )

    assert_not validator.valid?
    assert_includes validator.errors, "Maximum 7 players from one team"
  end

  private

  def create_match
    Match.create!(
      team_a: "Royal Challengers Bengaluru",
      team_b: "Mumbai Indians",
      team_a_short: "RCB",
      team_b_short: "MI",
      match_date: 1.day.from_now,
      lock_time: 1.day.from_now - 15.minutes,
      venue: "M. Chinnaswamy Stadium",
      format: "T20"
    )
  end

  def create_player(name, role, team)
    Player.create!(
      name: name,
      short_name: name,
      role: role,
      team: team,
      country: "India",
      base_price: 8.0
    )
  end
end
