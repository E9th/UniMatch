class MatchesController < ApplicationController
  before_action :require_login

  def index
    @matches = current_user.find_matches
  end

  # สร้าง Icebreaker ด้วย AI
  def icebreaker
    @match_user = User.find(params[:id])

    prompt_service = AiService.new
    @suggestion = prompt_service.generate_icebreaker(current_user, @match_user)

    respond_to do |format|
      format.html { redirect_to matches_path }
      format.json { render json: { message: @suggestion } }
      format.turbo_stream
    end
  end

  # เริ่มแชทกับเพื่อนที่ Match
  def start_chat
    @match_user = User.find(params[:id])

    # หา ChatRoom ที่มีอยู่แล้วระหว่าง 2 คนนี้ หรือสร้างใหม่
    chat_room = find_or_create_chat_room(@match_user)

    redirect_to chat_room_path(chat_room)
  end

  private

  def find_or_create_chat_room(other_user)
    # หาห้องแชทที่มีทั้ง 2 คน (ไม่ใช่ AI mode)
    my_room_ids = current_user.chat_rooms.where(is_ai_mode: false).pluck(:id)
    existing_room = other_user.chat_rooms.where(id: my_room_ids, is_ai_mode: false).first

    return existing_room if existing_room

    # สร้างห้องใหม่
    room = ChatRoom.create!(
      name: "#{current_user.name} & #{other_user.name}",
      is_ai_mode: false,
      user: current_user
    )
    ChatRoomMembership.create!(user: current_user, chat_room: room)
    ChatRoomMembership.create!(user: other_user, chat_room: room)

    room
  end
end
