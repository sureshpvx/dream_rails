class ContestChannel < ApplicationCable::Channel
  def subscribed
    contest = Contest.find(params[:contest_id])
    stream_for contest
  end
end
