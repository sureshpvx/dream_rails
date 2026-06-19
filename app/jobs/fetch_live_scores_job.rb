class FetchLiveScoresJob < ApplicationJob
  queue_as :default

  def perform
    Match.live.find_each do |match|
      ScoreEventProcessor.new(match).process_live!
      MatchChannel.broadcast_to(match, { type: "score_update", match_id: match.id, score: match.score_summary })
    end
  end
end
