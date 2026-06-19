class ScoreEventProcessor
  def initialize(match)
    @match = match
    @calculator = PointsCalculator.new
  end

  def process_live!
    match.match_players.includes(:player).find_each do |match_player|
      match_player.update!(fantasy_points: calculator.match_player_points(match_player))
    end

    match.user_teams.includes(:user_team_players).find_each(&:recalculate_points!)
  end

  private

  attr_reader :match, :calculator
end
