class UserTeam < ApplicationRecord
  enum :status, {
    draft: "draft",
    submitted: "submitted",
    live: "live",
    completed: "completed",
    cancelled: "cancelled"
  }, validate: true

  belongs_to :user
  belongs_to :contest
  belongs_to :match
  belongs_to :captain, class_name: "Player"
  belongs_to :vice_captain, class_name: "Player"
  has_many :user_team_players, dependent: :destroy
  has_many :players, through: :user_team_players

  validates :team_name, presence: true
  validates :user_id, uniqueness: { scope: :contest_id, message: "You already have a team in this contest" }
  validate :captain_and_vice_captain_are_different
  validate :contest_belongs_to_match

  scope :leaderboard, -> { order(total_points: :desc, created_at: :asc) }

  def recalculate_points!
    update!(total_points: PointsCalculator.new.team_points(self))
  end

  def selected_player_ids
    user_team_players.map(&:player_id)
  end

  private

  def captain_and_vice_captain_are_different
    return if captain_id.blank? || vice_captain_id.blank? || captain_id != vice_captain_id

    errors.add(:vice_captain, "Captain and Vice-Captain must be different")
  end

  def contest_belongs_to_match
    return if contest.blank? || match.blank? || contest.match_id == match_id

    errors.add(:contest, "does not belong to this match")
  end
end
