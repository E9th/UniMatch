class MessagesController < ApplicationController
  before_action :require_login

  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @message = @chat_room.messages.build(message_params)
    @message.user = current_user
    @message.role = "user"

    if @message.save
      @chat_room.touch # อัปเดต updated_at

      # ถ้าเป็น AI mode ให้ AI ตอบกลับ
      if @chat_room.is_ai_mode?
        AiResponseJob.perform_later(@message.id)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_room_path(@chat_room) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { chat_room: @chat_room, message: @message }) }
        format.html { redirect_to chat_room_path(@chat_room), alert: "ส่งข้อความไม่สำเร็จ" }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
