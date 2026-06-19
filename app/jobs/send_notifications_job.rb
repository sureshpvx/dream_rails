class SendNotificationsJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)
    UserChannel.broadcast_to(notification.user, notification.as_json(only: [:id, :title, :body, :notification_type]))
  end
end
