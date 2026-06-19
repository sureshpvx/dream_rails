class ContestsController < ApplicationController
  def index
    @match = Match.find(params[:match_id]) if params[:match_id].present?
    @contests = (@match&.contests || Contest).includes(:match).order(entry_fee: :asc, total_spots: :asc)
  end

  def show
    @contest = Contest.includes(:match, user_teams: [:user, :players]).find(params[:id])
    @leaderboard = @contest.user_teams.includes(:user).leaderboard
    @user_team = @contest.user_teams.find_by(user: current_user)
  end

  def join
    redirect_to new_contest_team_path(Contest.find(params[:id]))
  end
end
