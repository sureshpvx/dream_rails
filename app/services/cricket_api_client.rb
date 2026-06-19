require "net/http"
require "json"

class CricketApiClient
  BASE_URL = "https://api.cricapi.com/v1"

  def initialize(api_key: ENV["CRICAPI_KEY"])
    @api_key = api_key
  end

  def current_matches
    fetch_json("/currentMatches").fetch("data", [])
  end

  def match_info(api_match_id)
    fetch_json("/match_info", id: api_match_id).fetch("data", {})
  end

  private

  attr_reader :api_key

  def fetch_json(path, params = {})
    raise ArgumentError, "CRICAPI_KEY is not configured" if api_key.blank?

    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params.merge(apikey: api_key))
    response = Net::HTTP.get_response(uri)
    raise "CricAPI request failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end
end
