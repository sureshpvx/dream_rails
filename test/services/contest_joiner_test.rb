require "test_helper"

class ContestJoinerTest < ActiveSupport::TestCase
  test "creates a submitted team and debits the entry fee atomically" do
    user = User.create!(
      email: "joiner@example.test",
      encrypted_password: "secret",
      username: "joiner",
      virtual_balance: 1000,
      country_code: "IN"
    )
    match = create_match
    contest = Contest.create!(
      match: match,
      name: "RCB vs MI - Small League",
      entry_fee: 50,
      total_spots: 8,
      contest_type: "small",
      winner_count: 3
    )
    players = valid_players
    players.each { |player| MatchPlayer.create!(match: match, player: player) }

    result = ContestJoiner.new(
      user: user,
      contest: contest,
      team_params: {
        team_name: "Test XI",
        player_ids: players.map(&:id),
        captain_id: players.first.id,
        vice_captain_id: players.second.id
      }
    ).call

    assert result.success?, result.errors.join(", ")
    assert_equal 1, contest.reload.filled_spots
    assert_equal BigDecimal("950.0"), user.reload.virtual_balance
    assert_equal BigDecimal("-50.0"), user.transactions.entry_fee.last.amount
    assert_equal 11, result.user_team.players.count
    assert_equal "submitted", result.user_team.status
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

  def valid_players
    [
      create_player("A WK", "wicket_keeper", "RCB"),
      create_player("A BAT 1", "batsman", "RCB"),
      create_player("A BAT 2", "batsman", "RCB"),
      create_player("A BAT 3", "batsman", "RCB"),
      create_player("B BAT 1", "batsman", "MI"),
      create_player("A AR", "all_rounder", "RCB"),
      create_player("B AR", "all_rounder", "MI"),
      create_player("A BOW 1", "bowler", "RCB"),
      create_player("A BOW 2", "bowler", "RCB"),
      create_player("B BOW 1", "bowler", "MI"),
      create_player("B BOW 2", "bowler", "MI")
    ]
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
