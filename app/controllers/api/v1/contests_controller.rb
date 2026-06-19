module Api
  module V1
    class ContestsController < ApplicationController
      def index
        match = Match.find(params[:match_id])
        render json: match.contests.order(entry_fee: :asc)
      end

      def show
        contest = Contest.includes(user_teams: :user).find(params[:id])
        render json: contest.as_json(
          include: {
            user_teams: {
              only: [:id, :team_name, :total_points, :rank, :prize_won],
              include: { user: { only: [:id, :username] } }
            }
          },
          methods: [:progress_percentage, :spots_left]
        )
      end
    end
  end
end
