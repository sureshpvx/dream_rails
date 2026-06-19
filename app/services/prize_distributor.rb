class PrizeDistributor
  SMALL_CONTEST_SPLIT = [0.50, 0.30, 0.20].freeze

  def initialize(contest)
    @contest = contest
  end

  def distribute!
    return if contest.practice? || contest.cancelled?

    ranked_teams.each_with_index do |user_team, index|
      rank = index + 1
      prize = prize_for_rank(rank)

      user_team.update!(rank: rank, prize_won: prize, status: "completed")
      next unless prize.positive?

      user_team.user.credit!(
        amount: prize,
        transaction_type: "prize",
        reference: contest,
        description: "Prize for #{contest.name}",
        metadata: { rank: rank, user_team_id: user_team.id }
      )
    end

    contest.update!(status: "completed")
  end

  private

  attr_reader :contest

  def ranked_teams
    @ranked_teams ||= contest.user_teams.leaderboard.to_a
  end

  def prize_for_rank(rank)
    pool = BigDecimal(contest.prize_pool.to_s)

    if contest.head_to_head?
      rank == 1 ? pool : BigDecimal("0")
    elsif contest.small?
      percentage = SMALL_CONTEST_SPLIT[rank - 1] || 0
      pool * BigDecimal(percentage.to_s)
    elsif contest.mega?
      mega_prize_for_rank(rank, pool)
    else
      BigDecimal("0")
    end
  end

  def mega_prize_for_rank(rank, pool)
    case rank
    when 1 then pool * BigDecimal("0.20")
    when 2 then pool * BigDecimal("0.10")
    when 3 then pool * BigDecimal("0.05")
    when 4..10 then (pool * BigDecimal("0.15")) / 7
    when 11..50 then (pool * BigDecimal("0.20")) / 40
    else BigDecimal("0")
    end
  end
end
