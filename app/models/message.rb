class Message < ApplicationRecord
  belongs_to :user, optional: true # AI messages don't have a user
  belongs_to :chat_room

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant system] }

  # Default role
  after_initialize do
    self.role ||= "user"
  end

  # Broadcast ข้อความใหม่ผ่าน Turbo Stream (per-user สำหรับ alignment ที่ถูกต้อง)
  after_create_commit do
    chat_room.members.each do |member|
      broadcast_append_to "chat_room_#{chat_room_id}_user_#{member.id}",
        target: "messages",
        partial: "messages/message",
        locals: { message: self, viewing_user_id: member.id }
    end
  end

  def from_ai?
    role == "assistant"
  end

  def system_message?
    role == "system"
  end

  def sender_name
    from_ai? ? "AI ติวเตอร์" : (user&.name || "เพื่อนติว")
  end
end
