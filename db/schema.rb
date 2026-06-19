# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_19_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contests", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.string "name", null: false
    t.decimal "entry_fee", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "total_spots", null: false
    t.integer "filled_spots", default: 0, null: false
    t.decimal "prize_pool", precision: 10, scale: 2, default: "0.0", null: false
    t.string "contest_type", null: false
    t.string "status", default: "open", null: false
    t.integer "min_players", default: 2, null: false
    t.integer "max_players"
    t.boolean "guaranteed_prize", default: false, null: false
    t.boolean "is_private", default: false, null: false
    t.string "invite_code"
    t.bigint "created_by_id"
    t.integer "winner_count", default: 1, null: false
    t.decimal "platform_fee_percentage", precision: 4, scale: 2, default: "10.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_contests_on_created_by_id"
    t.index ["invite_code"], name: "index_contests_on_invite_code", unique: true, where: "(invite_code IS NOT NULL)"
    t.index ["match_id"], name: "index_contests_on_match_id"
    t.index ["status"], name: "index_contests_on_status"
  end

  create_table "match_players", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.boolean "is_playing_xi", default: false, null: false
    t.integer "batting_position"
    t.decimal "fantasy_points", precision: 6, scale: 2, default: "0.0", null: false
    t.integer "runs_scored", default: 0, null: false
    t.integer "balls_faced", default: 0, null: false
    t.integer "fours", default: 0, null: false
    t.integer "sixes", default: 0, null: false
    t.integer "wickets_taken", default: 0, null: false
    t.decimal "overs_bowled", precision: 4, scale: 1, default: "0.0", null: false
    t.integer "maidens", default: 0, null: false
    t.integer "catches", default: 0, null: false
    t.integer "run_outs", default: 0, null: false
    t.integer "stumpings", default: 0, null: false
    t.decimal "economy_rate", precision: 5, scale: 2
    t.decimal "strike_rate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id", "player_id"], name: "index_match_players_on_match_id_and_player_id", unique: true
    t.index ["match_id"], name: "index_match_players_on_match_id"
    t.index ["player_id"], name: "index_match_players_on_player_id"
  end

  create_table "matches", force: :cascade do |t|
    t.string "api_match_id"
    t.string "team_a", null: false
    t.string "team_b", null: false
    t.string "team_a_short", null: false
    t.string "team_b_short", null: false
    t.datetime "match_date", null: false
    t.string "venue", null: false
    t.string "venue_city"
    t.string "format", null: false
    t.string "status", default: "upcoming", null: false
    t.string "toss_winner"
    t.string "toss_decision"
    t.string "winner_team"
    t.string "margin"
    t.bigint "man_of_the_match_id"
    t.string "team_a_score"
    t.string "team_b_score"
    t.decimal "team_a_overs", precision: 4, scale: 1
    t.decimal "team_b_overs", precision: 4, scale: 1
    t.boolean "is_featured", default: false, null: false
    t.datetime "lock_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_match_id"], name: "index_matches_on_api_match_id", unique: true
    t.index ["is_featured"], name: "index_matches_on_is_featured"
    t.index ["man_of_the_match_id"], name: "index_matches_on_man_of_the_match_id"
    t.index ["match_date"], name: "index_matches_on_match_date"
    t.index ["status"], name: "index_matches_on_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "notification_type", null: false
    t.datetime "read_at"
    t.string "reference_type"
    t.bigint "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["reference_type", "reference_id"], name: "index_notifications_on_reference"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.string "role", null: false
    t.string "team", null: false
    t.string "country", null: false
    t.decimal "base_price", precision: 4, scale: 1, null: false
    t.string "batting_style"
    t.string "bowling_style"
    t.string "image_url"
    t.boolean "is_active", default: true, null: false
    t.jsonb "stats_json", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_players_on_is_active"
    t.index ["role"], name: "index_players_on_role"
    t.index ["team"], name: "index_players_on_team"
  end

  create_table "score_events", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.string "event_type", null: false
    t.string "ball_number"
    t.decimal "points", precision: 5, scale: 2, null: false
    t.jsonb "raw_data", default: {}, null: false
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_score_events_on_created_at"
    t.index ["match_id", "player_id", "ball_number", "event_type"], name: "idx_score_events_idempotency", unique: true, where: "(ball_number IS NOT NULL)"
    t.index ["match_id"], name: "index_score_events_on_match_id"
    t.index ["player_id"], name: "index_score_events_on_player_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_type", null: false
    t.string "reference_type"
    t.bigint "reference_id"
    t.decimal "balance_after", precision: 10, scale: 2, null: false
    t.string "description"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["reference_type", "reference_id"], name: "index_transactions_on_reference"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_team_players", force: :cascade do |t|
    t.bigint "user_team_id", null: false
    t.bigint "player_id", null: false
    t.boolean "is_captain", default: false, null: false
    t.boolean "is_vice_captain", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_user_team_players_on_player_id"
    t.index ["user_team_id", "player_id"], name: "index_user_team_players_on_user_team_id_and_player_id", unique: true
    t.index ["user_team_id"], name: "index_user_team_players_on_user_team_id"
  end

  create_table "user_teams", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contest_id", null: false
    t.bigint "match_id", null: false
    t.bigint "captain_id", null: false
    t.bigint "vice_captain_id", null: false
    t.decimal "total_points", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "rank"
    t.decimal "prize_won", precision: 10, scale: 2, default: "0.0", null: false
    t.string "status", default: "draft", null: false
    t.string "team_name", default: "Dream Team", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["captain_id"], name: "index_user_teams_on_captain_id"
    t.index ["contest_id"], name: "index_user_teams_on_contest_id"
    t.index ["match_id"], name: "index_user_teams_on_match_id"
    t.index ["user_id", "contest_id"], name: "index_user_teams_on_user_id_and_contest_id", unique: true
    t.index ["user_id"], name: "index_user_teams_on_user_id"
    t.index ["vice_captain_id"], name: "index_user_teams_on_vice_captain_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "username", null: false
    t.decimal "virtual_balance", precision: 10, scale: 2, default: "10000.0", null: false
    t.string "phone"
    t.string "avatar_url"
    t.date "date_of_birth"
    t.string "country_code", limit: 2, default: "IN", null: false
    t.string "state_code"
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "email_verified_at"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true, where: "(phone IS NOT NULL)"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "contests", "matches"
  add_foreign_key "contests", "users", column: "created_by_id"
  add_foreign_key "match_players", "matches"
  add_foreign_key "match_players", "players"
  add_foreign_key "matches", "players", column: "man_of_the_match_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "score_events", "matches"
  add_foreign_key "score_events", "players"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_team_players", "players"
  add_foreign_key "user_team_players", "user_teams"
  add_foreign_key "user_teams", "contests"
  add_foreign_key "user_teams", "matches"
  add_foreign_key "user_teams", "players", column: "captain_id"
  add_foreign_key "user_teams", "players", column: "vice_captain_id"
  add_foreign_key "user_teams", "users"
end
