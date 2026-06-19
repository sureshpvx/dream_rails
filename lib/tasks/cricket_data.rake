namespace :cricket do
  desc "Fetch upcoming matches from CricAPI"
  task fetch_upcoming_matches: :environment do
    client = CricketApiClient.new

    client.current_matches.each do |match_data|
      next if match_data["teams"].blank? || match_data["dateTimeGMT"].blank?

      match = Match.find_or_initialize_by(api_match_id: match_data["id"])
      team_info = Array(match_data["teamInfo"])
      match.assign_attributes(
        team_a: match_data["teams"][0],
        team_b: match_data["teams"][1],
        team_a_short: team_info.dig(0, "shortname").presence || match_data["teams"][0].to_s.first(3).upcase,
        team_b_short: team_info.dig(1, "shortname").presence || match_data["teams"][1].to_s.first(3).upcase,
        match_date: Time.zone.parse(match_data["dateTimeGMT"]),
        venue: match_data["venue"],
        format: match_data["matchType"].to_s.upcase.presence || "T20",
        lock_time: Time.zone.parse(match_data["dateTimeGMT"]) - 15.minutes
      )
      match.save!
    end
  end

  desc "Recalculate live match fantasy points"
  task fetch_live_scores: :environment do
    FetchLiveScoresJob.perform_now
  end

  desc "Distribute prizes for completed contests"
  task distribute_prizes: :environment do
    Contest.completed.find_each { |contest| PrizeDistributor.new(contest).distribute! }
  end
end
