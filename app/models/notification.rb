class Notification < ApplicationRecord
  enum :notification_type, {
    contest_full: "contest_full",
    match_live: "match_live",
    match_completed: "match_completed",
    prize_won: "prize_won",
    team_reminder: "team_reminder"
  }, validate: true

  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  validates :title, :body, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
end
