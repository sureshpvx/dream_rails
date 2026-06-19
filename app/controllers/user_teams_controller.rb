class UserTeamsController < ApplicationController
  before_action :set_contest, only: [:new, :create]

  def index
    @user_teams = current_user.user_teams.includes(:contest, :match, :players).order(created_at: :desc)
  end

  def show
    @user_team = current_user.user_teams.includes(:contest, :match, user_team_players: :player).find(params[:id])
  end

  def new
    return redirect_to contest_path(@contest), alert: "You already have a team in this contest." if @contest.user_teams.exists?(user: current_user)

    load_team_builder
  end

  def create
    result = ContestJoiner.new(user: current_user, contest: @contest, team_params: team_params).call

    if result.success?
      redirect_to contest_path(@contest), notice: "Team submitted! Good luck!"
    else
      @team_errors = result.errors
      load_team_builder
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_contest
    @contest = Contest.includes(match: { match_players: :player }).find(params[:contest_id])
  end

  def load_team_builder
    @match = @contest.match
    @match_players = @match.match_players.includes(:player).sort_by { |match_player| [role_sort(match_player.player.role), match_player.player.team, match_player.player.name] }
  end

  def role_sort(role)
    { "wicket_keeper" => 0, "batsman" => 1, "all_rounder" => 2, "bowler" => 3 }.fetch(role, 4)
  end

  def team_params
    params.require(:user_team).permit(:team_name, :captain_id, :vice_captain_id, player_ids: [])
  end
end
