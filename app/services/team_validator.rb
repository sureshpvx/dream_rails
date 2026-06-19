class TeamValidator
  ROLE_LIMITS = {
    "wicket_keeper" => (1..4),
    "batsman" => (3..6),
    "bowler" => (3..6),
    "all_rounder" => (1..4)
  }.freeze

  ROLE_MESSAGES = {
    "wicket_keeper" => "Select 1-4 Wicket-Keepers",
    "batsman" => "Select 3-6 Batsmen",
    "bowler" => "Select 3-6 Bowlers",
    "all_rounder" => "Select 1-4 All-Rounders"
  }.freeze

  attr_reader :match, :player_ids, :captain_id, :vice_captain_id, :errors

  def initialize(match:, player_ids:, captain_id:, vice_captain_id:)
    @match = match
    @player_ids = Array(player_ids).reject(&:blank?).map(&:to_i).uniq
    @captain_id = captain_id.to_i if captain_id.present?
    @vice_captain_id = vice_captain_id.to_i if vice_captain_id.present?
    @errors = []
  end

  def valid?
    validate
    errors.empty?
  end

  def selected_players
    @selected_players ||= Player.where(id: player_ids).to_a
  end

  def budget_spent
    selected_players.sum { |player| BigDecimal(player.base_price.to_s) }
  end

  def credits_remaining
    BigDecimal("100.0") - budget_spent
  end

  def role_counts
    selected_players.each_with_object(Hash.new(0)) { |player, counts| counts[player.role] += 1 }
  end

  def team_counts
    selected_players.each_with_object(Hash.new(0)) { |player, counts| counts[player.team] += 1 }
  end

  private

  def validate
    errors.clear

    errors << "Team selection is locked for this match" if match.locked?
    errors << "Your team must have exactly 11 players" unless player_ids.size == 11
    errors << "Invalid player selection" if selected_players.size != player_ids.size
    errors << "Team cost exceeds 100 credits" if budget_spent > 100
    errors << "Please select a Captain" if captain_id.blank?
    errors << "Please select a Vice-Captain" if vice_captain_id.blank?
    errors << "Captain and Vice-Captain must be different" if captain_id.present? && captain_id == vice_captain_id
    errors << "Invalid player selection" if (player_ids - match.players.ids).any?
    errors << "Please select a Captain" if captain_id.present? && player_ids.exclude?(captain_id)
    errors << "Please select a Vice-Captain" if vice_captain_id.present? && player_ids.exclude?(vice_captain_id)

    ROLE_LIMITS.each do |role, range|
      errors << ROLE_MESSAGES.fetch(role) unless range.cover?(role_counts[role])
    end

    errors << "Maximum 7 players from one team" if team_counts.values.any? { |count| count > 7 }
  end
end
