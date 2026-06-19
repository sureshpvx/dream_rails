class DistributePrizesJob < ApplicationJob
  queue_as :default

  def perform(contest_id)
    PrizeDistributor.new(Contest.find(contest_id)).distribute!
  end
end
