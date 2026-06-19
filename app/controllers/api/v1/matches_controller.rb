module Api
  module V1
    class MatchesController < ApplicationController
      def index
        matches = Match.includes(:contests).chronological
        render json: matches.as_json(
          only: [:id, :team_a, :team_b, :team_a_short, :team_b_short, :match_date, :venue, :format, :status, :lock_time],
          methods: [:matchup, :score_summary]
        )
      end

      def show
        match = Match.includes(:players, :contests).find(params[:id])
        render json: match.as_json(
          include: {
            players: { only: [:id, :name, :short_name, :role, :team, :country, :base_price] },
            contests: { only: [:id, :name, :entry_fee, :total_spots, :filled_spots, :prize_pool, :contest_type, :status] }
          },
          methods: [:matchup, :score_summary]
        )
      end
    end
  end
end
