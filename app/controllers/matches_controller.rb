class MatchesController < ApplicationController
  def index
    @status = params[:status].presence
    @matches = Match.includes(:contests).chronological
    @matches = @matches.where(status: @status) if @status.present?
  end

  def show
    @match = Match.includes(:players, contests: :user_teams).find(params[:id])
    @contests = @match.contests.order(entry_fee: :asc, total_spots: :asc)
    @squad = @match.match_players.includes(:player).sort_by { |match_player| [match_player.player.team, match_player.player.role, match_player.player.name] }
  end
end
