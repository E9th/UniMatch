class ChatRoomsController < ApplicationController
  before_action :require_login

  def index
    @chat_rooms = current_user.chat_rooms.includes(:messages, :members, :chat_room_memberships).order(updated_at: :desc)
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

    # เตรียมข้อมูลสำหรับ reveal identity
    unless @chat_room.is_ai_mode?
      @my_membership = @chat_room.chat_room_memberships.find_by(user: current_user)
      @other_user = @chat_room.other_member(current_user)
      @other_revealed = @chat_room.identity_revealed?(@other_user) if @other_user
      @my_review = Review.find_by(reviewer: current_user, chat_room: @chat_room)
      @other_user_avg_rating = @other_user&.average_rating || 0.0
      @other_user_review_count = @other_user&.review_count || 0

      # Read receipts
      @other_membership = @chat_room.chat_room_memberships.find_by(user: @other_user) if @other_user
      @other_last_read_at = @other_membership&.last_read_at

      # Mark current user as having read
      @my_membership&.update_column(:last_read_at, Time.current)
    end
  end

  # สร้าง AI Chat Room
  def create_ai_room
    room = current_user.ai_chat_room
    ChatRoomMembership.find_or_create_by!(user: current_user, chat_room: room)
    redirect_to chat_room_path(room)
  end

  # ดูโปรไฟล์คู่สนทนา
  def partner_profile
    @chat_room = ChatRoom.find(params[:id])

    unless @chat_room.members.include?(current_user) || @chat_room.user == current_user
      redirect_to chat_rooms_path, alert: "คุณไม่มีสิทธิ์เข้าถึง"
      return
    end

    if @chat_room.is_ai_mode?
      redirect_to chat_room_path(@chat_room)
      return
    end

    @other_user = @chat_room.other_member(current_user)
    unless @other_user
      redirect_to chat_room_path(@chat_room), alert: "ไม่พบข้อมูลคู่สนทนา"
      return
    end

    @other_revealed = @chat_room.identity_revealed?(@other_user)
  end

  # เปิดเผยตัวตน
  def reveal_identity
    @chat_room = ChatRoom.find(params[:id])
    membership = @chat_room.chat_room_memberships.find_by(user: current_user)

    if membership
      membership.update!(identity_revealed: true)

      # ส่งข้อความแจ้งในห้องแชท
      Message.create!(
        chat_room: @chat_room,
        user: nil,
        content: "🎉 #{current_user.name} ได้เปิดเผยตัวตนแล้ว!",
        role: "system"
      )

      redirect_to chat_room_path(@chat_room), notice: "เปิดเผยตัวตนสำเร็จ!"
    else
      redirect_to chat_room_path(@chat_room), alert: "ไม่สามารถดำเนินการได้"
    end
  end
end
