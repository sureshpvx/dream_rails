class Match < ApplicationRecord
  FORMATS = %w[T20 ODI Test T10].freeze

  enum :status, {
    upcoming: "upcoming",
    live: "live",
    completed: "completed",
    cancelled: "cancelled",
    abandoned: "abandoned"
  }, validate: true

  enum :toss_decision, {
    bat: "bat",
    field: "field"
  }, prefix: true, validate: { allow_nil: true }

  belongs_to :man_of_the_match, class_name: "Player", optional: true
  has_many :contests, dependent: :destroy
  has_many :match_players, dependent: :destroy
  has_many :players, through: :match_players
  has_many :score_events, dependent: :destroy
  has_many :user_teams, dependent: :destroy

  before_validation :assign_lock_time

  validates :team_a, :team_b, :team_a_short, :team_b_short, :match_date, :venue, presence: true
  validates :format, inclusion: { in: FORMATS }
  validates :api_match_id, uniqueness: true, allow_blank: true

  scope :featured, -> { where(is_featured: true) }
  scope :chronological, -> { order(match_date: :asc) }
  scope :recent_first, -> { order(match_date: :desc) }

  def matchup
    "#{team_a_short} vs #{team_b_short}"
  end

  def locked?
    lock_time.present? && Time.current >= lock_time
  end

  def lock_countdown
    return "Locked" if locked?

    distance = lock_time - Time.current
    hours = (distance / 1.hour).floor
    minutes = ((distance % 1.hour) / 1.minute).floor
    "#{hours}h #{minutes}m"
  end

  def score_summary
    return "Starts #{match_date.strftime("%b %-d, %l:%M %p")}" if upcoming?
    return "Result: #{winner_team} won by #{margin}" if completed? && winner_team.present?

    [team_a_score, team_b_score].compact.join("  |  ").presence || "Scores pending"
  end

  private

  def assign_lock_time
    self.lock_time ||= match_date - 15.minutes if match_date.present?
  end
end
