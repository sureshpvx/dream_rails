class ContestJoiner
  Result = Struct.new(:success, :user_team, :errors, keyword_init: true) do
    def success?
      success
    end
  end

  def initialize(user:, contest:, team_params:)
    @user = user
    @contest = contest
    @team_params = team_params
  end

  def call
    validator = TeamValidator.new(
      match: contest.match,
      player_ids: team_params[:player_ids],
      captain_id: team_params[:captain_id],
      vice_captain_id: team_params[:vice_captain_id]
    )

    return failure(validator.errors) unless validator.valid?

    user_team = nil

    ActiveRecord::Base.transaction do
      contest.lock!

      return failure(["This contest is full. Check out other contests!"]) unless contest.joinable? && contest.spots_left.positive?
      return failure(["Team selection is locked. Match starts in #{contest.match.lock_countdown}."]) if contest.match.locked?
      return failure(["You already have a team in this contest."]) if UserTeam.exists?(user: user, contest: contest)

      debit_entry_fee!

      user_team = UserTeam.create!(
        user: user,
        contest: contest,
        match: contest.match,
        captain_id: team_params[:captain_id],
        vice_captain_id: team_params[:vice_captain_id],
        team_name: team_params[:team_name].presence || "#{user.username}'s XI",
        status: "submitted"
      )

      team_params[:player_ids].reject(&:blank?).map(&:to_i).uniq.each do |player_id|
        user_team.user_team_players.create!(
          player_id: player_id,
          is_captain: player_id == user_team.captain_id,
          is_vice_captain: player_id == user_team.vice_captain_id
        )
      end

      user_team.recalculate_points!
      contest.update!(
        filled_spots: contest.filled_spots + 1,
        status: contest.filled_spots + 1 >= contest.total_spots ? "full" : "filling"
      )
    end

    Result.new(success: true, user_team: user_team, errors: [])
  rescue User::InsufficientBalance
    failure(["Insufficient balance. Add more play money."])
  rescue ActiveRecord::RecordInvalid => error
    failure(error.record.errors.full_messages)
  end

  private

  attr_reader :user, :contest, :team_params

  def debit_entry_fee!
    return if contest.entry_fee.zero?

    user.debit!(
      amount: contest.entry_fee,
      transaction_type: "entry_fee",
      reference: contest,
      description: "Entry fee for #{contest.name}",
      metadata: { contest_id: contest.id, match_id: contest.match_id }
    )
  end

  def failure(errors)
    Result.new(success: false, user_team: nil, errors: Array(errors))
  end
end
