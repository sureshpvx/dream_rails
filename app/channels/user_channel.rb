class UserChannel < ApplicationCable::Channel
  def subscribed
    user = User.find(params[:user_id])
    stream_for user
  end
end
