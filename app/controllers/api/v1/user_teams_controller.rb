module Api
  module V1
    class UserTeamsController < ApplicationController
      def index
        render json: current_user.user_teams.includes(:contest, :match, :players).as_json(
          include: {
            contest: { only: [:id, :name, :entry_fee, :prize_pool] },
            match: { only: [:id, :team_a_short, :team_b_short, :status] },
            players: { only: [:id, :name, :role, :team, :base_price] }
          }
        )
      end
    end
  end
end
