class HomeController < ApplicationController
  def index
    @featured_match = Match.featured.chronological.first || Match.chronological.first
    @matches = Match.includes(:contests).chronological.limit(6)
    @contests = Contest.includes(:match).available.order(created_at: :desc).limit(6)
    @leaderboard = UserTeam.includes(:user, :contest).leaderboard.limit(5)
    @notifications = current_user.notifications.recent.limit(5)
  end

  def leaderboard
    @leaderboard = UserTeam.includes(:user, :contest, :match).leaderboard.limit(50)
  end
end
