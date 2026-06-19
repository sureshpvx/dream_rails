now = Time.zone.now

demo_user = User.find_or_initialize_by(email: "demo@dreamrails.test")
demo_user.assign_attributes(
  encrypted_password: demo_user.encrypted_password.presence || SecureRandom.hex(24),
  username: "dreamer_demo",
  country_code: "IN",
  virtual_balance: demo_user.virtual_balance.presence || User::STARTING_BALANCE,
  email_verified_at: demo_user.email_verified_at || now
)
demo_user.save!

unless demo_user.transactions.signup_bonus.exists?
  demo_user.transactions.create!(
    amount: User::STARTING_BALANCE,
    transaction_type: "signup_bonus",
    balance_after: demo_user.virtual_balance,
    description: "Signup bonus"
  )
end

players = [
  ["Virat Kohli", "V. Kohli", "batsman", "RCB", "India", 10.5, "right_hand", nil],
  ["Faf du Plessis", "Faf", "batsman", "RCB", "South Africa", 9.5, "right_hand", nil],
  ["Rajat Patidar", "R. Patidar", "batsman", "RCB", "India", 8.5, "right_hand", nil],
  ["Glenn Maxwell", "G. Maxwell", "all_rounder", "RCB", "Australia", 9.0, "right_hand", "spin"],
  ["Cameron Green", "C. Green", "all_rounder", "RCB", "Australia", 8.5, "right_hand", "medium"],
  ["Dinesh Karthik", "D. Karthik", "wicket_keeper", "RCB", "India", 8.0, "right_hand", nil],
  ["Anuj Rawat", "A. Rawat", "wicket_keeper", "RCB", "India", 7.0, "left_hand", nil],
  ["Mohammed Siraj", "M. Siraj", "bowler", "RCB", "India", 8.5, "right_hand", "fast"],
  ["Yash Dayal", "Y. Dayal", "bowler", "RCB", "India", 7.0, "left_hand", "medium"],
  ["Karn Sharma", "K. Sharma", "bowler", "RCB", "India", 7.5, "left_hand", "leg_spin"],
  ["Akash Deep", "A. Deep", "bowler", "RCB", "India", 7.0, "right_hand", "fast"],
  ["Rohit Sharma", "R. Sharma", "batsman", "MI", "India", 10.0, "right_hand", nil],
  ["Suryakumar Yadav", "S. Yadav", "batsman", "MI", "India", 10.0, "right_hand", nil],
  ["Ishan Kishan", "I. Kishan", "wicket_keeper", "MI", "India", 9.0, "left_hand", nil],
  ["Hardik Pandya", "H. Pandya", "all_rounder", "MI", "India", 9.5, "right_hand", "medium"],
  ["Tim David", "T. David", "batsman", "MI", "Australia", 8.0, "right_hand", nil],
  ["Tilak Varma", "T. Varma", "batsman", "MI", "India", 8.5, "left_hand", nil],
  ["Jasprit Bumrah", "J. Bumrah", "bowler", "MI", "India", 9.5, "right_hand", "fast"],
  ["Piyush Chawla", "P. Chawla", "bowler", "MI", "India", 7.5, "left_hand", "leg_spin"],
  ["Gerald Coetzee", "G. Coetzee", "bowler", "MI", "South Africa", 8.0, "right_hand", "fast"],
  ["Nehal Wadhera", "N. Wadhera", "all_rounder", "MI", "India", 7.5, "left_hand", "spin"],
  ["Arjun Tendulkar", "A. Tendulkar", "bowler", "MI", "India", 6.5, "left_hand", "medium"]
]

player_records = players.each_with_object({}) do |(name, short_name, role, team, country, price, batting, bowling), records|
  player = Player.find_or_initialize_by(name: name)
  player.assign_attributes(
    short_name: short_name,
    role: role,
    team: team,
    country: country,
    base_price: price,
    batting_style: batting,
    bowling_style: bowling,
    is_active: true
  )
  player.save!
  records[name] = player
end

featured_match = Match.find_or_initialize_by(api_match_id: "seed-rcb-mi-upcoming")
featured_match.assign_attributes(
  team_a: "Royal Challengers Bengaluru",
  team_b: "Mumbai Indians",
  team_a_short: "RCB",
  team_b_short: "MI",
  match_date: now + 2.days,
  venue: "M. Chinnaswamy Stadium",
  venue_city: "Bengaluru",
  format: "T20",
  status: "upcoming",
  lock_time: now + 2.days - 15.minutes,
  is_featured: true
)
featured_match.save!

live_match = Match.find_or_initialize_by(api_match_id: "seed-csk-kkr-live")
live_match.assign_attributes(
  team_a: "Chennai Super Kings",
  team_b: "Kolkata Knight Riders",
  team_a_short: "CSK",
  team_b_short: "KKR",
  match_date: now - 30.minutes,
  venue: "MA Chidambaram Stadium",
  venue_city: "Chennai",
  format: "T20",
  status: "live",
  team_a_score: "92/3",
  team_a_overs: 11.2,
  lock_time: now - 45.minutes,
  is_featured: false
)
live_match.save!

completed_match = Match.find_or_initialize_by(api_match_id: "seed-dc-srh-completed")
completed_match.assign_attributes(
  team_a: "Delhi Capitals",
  team_b: "Sunrisers Hyderabad",
  team_a_short: "DC",
  team_b_short: "SRH",
  match_date: now - 2.days,
  venue: "Arun Jaitley Stadium",
  venue_city: "Delhi",
  format: "T20",
  status: "completed",
  winner_team: "Sunrisers Hyderabad",
  margin: "6 wickets",
  team_a_score: "178/6",
  team_b_score: "181/4",
  team_a_overs: 20,
  team_b_overs: 19.1,
  lock_time: now - 2.days - 15.minutes,
  is_featured: false
)
completed_match.save!

[featured_match, live_match, completed_match].each do |match|
  player_records.values.each_with_index do |player, index|
    match_player = MatchPlayer.find_or_initialize_by(match: match, player: player)
    match_player.assign_attributes(
      is_playing_xi: index < 22,
      batting_position: index + 1
    )
    match_player.save!
  end
end

score_seed = {
  "Virat Kohli" => { runs_scored: 72, balls_faced: 48, fours: 8, sixes: 2, strike_rate: 150.0 },
  "Faf du Plessis" => { runs_scored: 34, balls_faced: 21, fours: 4, sixes: 1, strike_rate: 161.9 },
  "Glenn Maxwell" => { runs_scored: 18, balls_faced: 12, fours: 1, sixes: 1, wickets_taken: 1, overs_bowled: 2, economy_rate: 7.5, strike_rate: 150.0 },
  "Mohammed Siraj" => { wickets_taken: 2, overs_bowled: 4, maidens: 1, economy_rate: 6.5 },
  "Jasprit Bumrah" => { wickets_taken: 3, overs_bowled: 4, maidens: 0, economy_rate: 5.5 },
  "Rohit Sharma" => { runs_scored: 44, balls_faced: 31, fours: 5, sixes: 1, strike_rate: 141.93 },
  "Suryakumar Yadav" => { runs_scored: 65, balls_faced: 33, fours: 7, sixes: 3, strike_rate: 196.96 },
  "Hardik Pandya" => { runs_scored: 22, balls_faced: 16, fours: 2, sixes: 1, wickets_taken: 1, overs_bowled: 3, economy_rate: 8.0, strike_rate: 137.5 }
}

score_seed.each do |name, attributes|
  [live_match, completed_match].each do |match|
    match_player = MatchPlayer.find_by!(match: match, player: player_records.fetch(name))
    match_player.update!(attributes)
  end
end

featured_match.update!(man_of_the_match: nil)
live_match.update!(man_of_the_match: player_records["Suryakumar Yadav"])
completed_match.update!(man_of_the_match: player_records["Jasprit Bumrah"])

contest_templates = [
  ["Practice Arena", 0, 100, "practice", 0, 0, true],
  ["Head-to-Head Low", 25, 2, "head_to_head", 1, 10, false],
  ["Head-to-Head High", 250, 2, "head_to_head", 1, 10, false],
  ["Small League", 50, 8, "small", 3, 10, false],
  ["Mega Contest", 100, 500, "mega", 250, 10, true]
]

[featured_match, live_match].each do |match|
  contest_templates.each do |name, entry_fee, spots, contest_type, winner_count, platform_fee, guaranteed|
    contest = Contest.find_or_initialize_by(match: match, name: "#{match.matchup} - #{name}")
    contest.assign_attributes(
      entry_fee: entry_fee,
      total_spots: spots,
      contest_type: contest_type,
      status: contest.filled_spots.to_i.positive? ? "filling" : "open",
      min_players: contest_type == "mega" ? 100 : 2,
      max_players: spots,
      guaranteed_prize: guaranteed,
      winner_count: winner_count,
      platform_fee_percentage: platform_fee
    )
    contest.save!
  end
end

demo_contest = featured_match.contests.practice.first
demo_player_names = [
  "Anuj Rawat",
  "Virat Kohli",
  "Faf du Plessis",
  "Rohit Sharma",
  "Suryakumar Yadav",
  "Glenn Maxwell",
  "Hardik Pandya",
  "Mohammed Siraj",
  "Yash Dayal",
  "Piyush Chawla",
  "Jasprit Bumrah"
]

unless UserTeam.exists?(user: demo_user, contest: demo_contest)
  ContestJoiner.new(
    user: demo_user,
    contest: demo_contest,
    team_params: {
      team_name: "Demo Dream XI",
      player_ids: demo_player_names.map { |name| player_records.fetch(name).id },
      captain_id: player_records.fetch("Virat Kohli").id,
      vice_captain_id: player_records.fetch("Suryakumar Yadav").id
    }
  ).call
end

[live_match, completed_match, featured_match].each { |match| ScoreEventProcessor.new(match).process_live! }
