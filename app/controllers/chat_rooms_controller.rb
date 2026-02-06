class ChatRoomsController < ApplicationController
  before_action :require_login

  def index
    @chat_rooms = current_user.chat_rooms.includes(:messages, :members).order(updated_at: :desc)
  end

  def show
    @chat_room = ChatRoom.find(params[:id])

    # ตรวจสอบว่า user เป็นสมาชิกของห้อง
    unless @chat_room.members.include?(current_user) || @chat_room.user == current_user
      flash[:alert] = "คุณไม่มีสิทธิ์เข้าถึงห้องแชทนี้"
      redirect_to chat_rooms_path and return
    end

    @messages = @chat_room.messages.order(created_at: :asc)
    @message = Message.new
  end

  # สร้าง AI Chat Room
  def create_ai_room
    room = current_user.ai_chat_room
    ChatRoomMembership.find_or_create_by!(user: current_user, chat_room: room)
    redirect_to chat_room_path(room)
  end
end
