class Contest < ApplicationRecord
  enum :contest_type, {
    head_to_head: "head_to_head",
    small: "small",
    mega: "mega",
    practice: "practice"
  }, validate: true

  enum :status, {
    open: "open",
    filling: "filling",
    full: "full",
    live: "live",
    completed: "completed",
    cancelled: "cancelled"
  }, validate: true

  belongs_to :match
  belongs_to :created_by, class_name: "User", optional: true
  has_many :user_teams, dependent: :destroy
  has_many :users, through: :user_teams

  before_validation :calculate_prize_pool

  validates :name, presence: true
  validates :entry_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :total_spots, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :filled_spots, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :winner_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :platform_fee_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :invite_code, uniqueness: true, allow_blank: true
  validate :filled_spots_cannot_exceed_total

  scope :available, -> { where(status: %w[open filling]) }

  def joinable?
    open? || filling?
  end

  def spots_left
    total_spots - filled_spots
  end

  def progress_percentage
    return 0 if total_spots.zero?

    ((filled_spots.to_f / total_spots) * 100).round
  end

  def mark_filled_if_needed!
    update!(status: "full") if filled_spots >= total_spots && !full?
  end

  private

  def calculate_prize_pool
    fee = BigDecimal(entry_fee.to_s.presence || "0")
    spots = total_spots.to_i
    platform_cut = BigDecimal(platform_fee_percentage.to_s.presence || "10") / 100
    self.prize_pool = fee * spots * (1 - platform_cut)
  end

  def filled_spots_cannot_exceed_total
    return if total_spots.blank? || filled_spots.blank? || filled_spots <= total_spots

    errors.add(:filled_spots, "cannot exceed total spots")
  end
end
