class AiResponseJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    user_message = Message.find(message_id)
    chat_room = user_message.chat_room
    user = user_message.user

    # เรียก AI Service (Groq)
    ai_reply_text = AiService.new.study_chat(user_message.content, user)

    # บันทึกคำตอบ AI
    Message.create!(
      content: ai_reply_text,
      role: "assistant",
      chat_room: chat_room,
      user: nil
    )
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AiResponseJob Error: Message #{message_id} not found - #{e.message}"
    raise
  rescue StandardError => e
    Rails.logger.error "AiResponseJob Error: #{e.message}"
    if user_message&.chat_room
      Message.create!(
        content: "ขอโทษด้วยครับ ระบบ AI มีปัญหาชั่วคราว กรุณาลองใหม่อีกครั้ง 🙏",
        role: "assistant",
        chat_room: user_message.chat_room,
        user: nil
      )
    end
  end
end
