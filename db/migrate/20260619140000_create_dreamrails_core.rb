class CreateDreamrailsCore < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :username, null: false
      t.decimal :virtual_balance, precision: 10, scale: 2, default: "10000.00", null: false
      t.string :phone
      t.string :avatar_url
      t.date :date_of_birth
      t.string :country_code, limit: 2, default: "IN", null: false
      t.string :state_code
      t.boolean :is_admin, default: false, null: false
      t.boolean :is_active, default: true, null: false
      t.datetime :email_verified_at
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :phone, unique: true, where: "phone IS NOT NULL"

    create_table :players do |t|
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :role, null: false
      t.string :team, null: false
      t.string :country, null: false
      t.decimal :base_price, precision: 4, scale: 1, null: false
      t.string :batting_style
      t.string :bowling_style
      t.string :image_url
      t.boolean :is_active, default: true, null: false
      t.jsonb :stats_json, default: {}, null: false

      t.timestamps
    end

    add_index :players, :role
    add_index :players, :team
    add_index :players, :is_active

    create_table :matches do |t|
      t.string :api_match_id
      t.string :team_a, null: false
      t.string :team_b, null: false
      t.string :team_a_short, null: false
      t.string :team_b_short, null: false
      t.datetime :match_date, null: false
      t.string :venue, null: false
      t.string :venue_city
      t.string :format, null: false
      t.string :status, default: "upcoming", null: false
      t.string :toss_winner
      t.string :toss_decision
      t.string :winner_team
      t.string :margin
      t.references :man_of_the_match, foreign_key: { to_table: :players }
      t.string :team_a_score
      t.string :team_b_score
      t.decimal :team_a_overs, precision: 4, scale: 1
      t.decimal :team_b_overs, precision: 4, scale: 1
      t.boolean :is_featured, default: false, null: false
      t.datetime :lock_time, null: false

      t.timestamps
    end

    add_index :matches, :api_match_id, unique: true
    add_index :matches, :match_date
    add_index :matches, :status
    add_index :matches, :is_featured

    create_table :match_players do |t|
      t.references :match, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.boolean :is_playing_xi, default: false, null: false
      t.integer :batting_position
      t.decimal :fantasy_points, precision: 6, scale: 2, default: "0.00", null: false
      t.integer :runs_scored, default: 0, null: false
      t.integer :balls_faced, default: 0, null: false
      t.integer :fours, default: 0, null: false
      t.integer :sixes, default: 0, null: false
      t.integer :wickets_taken, default: 0, null: false
      t.decimal :overs_bowled, precision: 4, scale: 1, default: "0.0", null: false
      t.integer :maidens, default: 0, null: false
      t.integer :catches, default: 0, null: false
      t.integer :run_outs, default: 0, null: false
      t.integer :stumpings, default: 0, null: false
      t.decimal :economy_rate, precision: 5, scale: 2
      t.decimal :strike_rate, precision: 5, scale: 2

      t.timestamps
    end

    add_index :match_players, [:match_id, :player_id], unique: true

    create_table :contests do |t|
      t.references :match, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :entry_fee, precision: 8, scale: 2, default: "0.00", null: false
      t.integer :total_spots, null: false
      t.integer :filled_spots, default: 0, null: false
      t.decimal :prize_pool, precision: 10, scale: 2, default: "0.00", null: false
      t.string :contest_type, null: false
      t.string :status, default: "open", null: false
      t.integer :min_players, default: 2, null: false
      t.integer :max_players
      t.boolean :guaranteed_prize, default: false, null: false
      t.boolean :is_private, default: false, null: false
      t.string :invite_code
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :winner_count, default: 1, null: false
      t.decimal :platform_fee_percentage, precision: 4, scale: 2, default: "10.00", null: false

      t.timestamps
    end

    add_index :contests, :status
    add_index :contests, :invite_code, unique: true, where: "invite_code IS NOT NULL"

    create_table :user_teams do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contest, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.references :captain, null: false, foreign_key: { to_table: :players }
      t.references :vice_captain, null: false, foreign_key: { to_table: :players }
      t.decimal :total_points, precision: 8, scale: 2, default: "0.00", null: false
      t.integer :rank
      t.decimal :prize_won, precision: 10, scale: 2, default: "0.00", null: false
      t.string :status, default: "draft", null: false
      t.string :team_name, default: "Dream Team", null: false

      t.timestamps
    end

    add_index :user_teams, [:user_id, :contest_id], unique: true
    create_table :user_team_players do |t|
      t.references :user_team, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.boolean :is_captain, default: false, null: false
      t.boolean :is_vice_captain, default: false, null: false

      t.timestamps
    end

    add_index :user_team_players, [:user_team_id, :player_id], unique: true

    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false
      t.references :reference, polymorphic: true
      t.decimal :balance_after, precision: 10, scale: 2, null: false
      t.string :description
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :transactions, :created_at

    create_table :score_events do |t|
      t.references :match, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :ball_number
      t.decimal :points, precision: 5, scale: 2, null: false
      t.jsonb :raw_data, default: {}, null: false
      t.datetime :processed_at

      t.timestamps
    end

    add_index :score_events, [:match_id, :player_id, :ball_number, :event_type],
      unique: true,
      where: "ball_number IS NOT NULL",
      name: "idx_score_events_idempotency"
    add_index :score_events, :created_at

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.string :notification_type, null: false
      t.datetime :read_at
      t.references :reference, polymorphic: true

      t.timestamps
    end

    add_index :notifications, :read_at
  end
end
