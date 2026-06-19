class PointsCalculator
  def match_player_points(match_player)
    points = batting_points(match_player) + bowling_points(match_player) + fielding_points(match_player)
    points += 10 if match_player.match.man_of_the_match_id == match_player.player_id
    points.round(2)
  end

  def team_points(user_team)
    match_players = user_team.match.match_players.includes(:player).index_by(&:player_id)

    user_team.user_team_players.includes(:player).sum do |team_player|
      match_player = match_players[team_player.player_id]
      next BigDecimal("0") unless match_player

      multiplier = if team_player.is_captain?
        BigDecimal("2.0")
      elsif team_player.is_vice_captain?
        BigDecimal("1.5")
      else
        BigDecimal("1.0")
      end

      match_player_points(match_player) * multiplier
    end.round(2)
  end

  private

  def batting_points(match_player)
    points = BigDecimal(match_player.runs_scored.to_s)
    points += match_player.fours
    points += match_player.sixes * 2
    points += 4 if match_player.runs_scored >= 50
    points += 8 if match_player.runs_scored >= 100
    points -= 2 if duck_penalty?(match_player)
    points + strike_rate_points(match_player)
  end

  def bowling_points(match_player)
    points = BigDecimal((match_player.wickets_taken * 25).to_s)
    points += match_player.maidens * 4
    points += 16 if match_player.wickets_taken >= 5
    points += 8 if match_player.wickets_taken == 4
    points += 4 if match_player.wickets_taken == 3
    points + economy_points(match_player)
  end

  def fielding_points(match_player)
    BigDecimal(((match_player.catches * 8) + (match_player.stumpings * 12) + (match_player.run_outs * 12)).to_s)
  end

  def strike_rate_points(match_player)
    return BigDecimal("0") if match_player.balls_faced < 10

    strike_rate = match_player.strike_rate || ((match_player.runs_scored.to_d / match_player.balls_faced) * 100)

    case strike_rate
    when 150.0001.. then BigDecimal("4")
    when 130.01..150 then BigDecimal("2")
    when 100..130 then BigDecimal("0")
    when 70..99.99 then BigDecimal("-2")
    else BigDecimal("-4")
    end
  end

  def economy_points(match_player)
    return BigDecimal("0") if match_player.overs_bowled < 2

    economy = match_player.economy_rate || 0

    case economy
    when ...4 then BigDecimal("4")
    when 4..5 then BigDecimal("2")
    when 5.01..6 then BigDecimal("0")
    when 6.01..9 then BigDecimal("-2")
    else BigDecimal("-4")
    end
  end

  def duck_penalty?(match_player)
    match_player.player.batsman? && match_player.runs_scored.zero? && match_player.balls_faced.positive?
  end
end
