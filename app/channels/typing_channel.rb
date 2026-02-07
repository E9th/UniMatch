class TypingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "typing_#{params[:chat_room_id]}"
  end

  def typing(data)
    ActionCable.server.broadcast(
      "typing_#{params[:chat_room_id]}",
      { user_id: current_user.id, typing: data["typing"] }
    )
  end
end
