class CleanupOldDataJob < ApplicationJob
  queue_as :default

  def perform
    Notification.where(read_at: ...30.days.ago).delete_all
  end
end
