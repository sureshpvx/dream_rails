class GeolocationService
  BLOCKED_INDIA_STATES = {
    "AP" => "Andhra Pradesh",
    "ANDHRA PRADESH" => "Andhra Pradesh",
    "TS" => "Telangana",
    "TG" => "Telangana",
    "TELANGANA" => "Telangana",
    "AS" => "Assam",
    "ASSAM" => "Assam",
    "OD" => "Odisha",
    "OR" => "Odisha",
    "ODISHA" => "Odisha",
    "ORISSA" => "Odisha"
  }.freeze

  BLOCKED_US_STATES = %w[AZ IA LA MT NV WA ARIZONA IOWA LOUISIANA MONTANA NEVADA WASHINGTON].freeze

  def self.blocked?(country_code:, state_code:)
    country = country_code.to_s.upcase
    state = state_code.to_s.strip.upcase

    return false if state.blank?
    return BLOCKED_INDIA_STATES.key?(state) if country == "IN"
    return BLOCKED_US_STATES.include?(state) if country == "US"

    false
  end
end
