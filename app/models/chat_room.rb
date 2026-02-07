class ChatRoom < ApplicationRecord
  belongs_to :user, optional: true # owner of the room
  has_many :messages, dependent: :destroy
  has_many :chat_room_memberships, dependent: :destroy
  has_many :members, through: :chat_room_memberships, source: :user

  validates :name, presence: true

  # ตรวจสอบว่าเป็นโหมด AI หรือไม่
  def is_ai_mode?
    is_ai_mode == true
  end

  # ข้อความล่าสุด
  def last_message
    messages.order(created_at: :desc).first
  end

  # ดูว่าผู้ใช้เปิดเผยตัวตนแล้วหรือยัง
  def identity_revealed?(user)
    chat_room_memberships.find_by(user: user)&.identity_revealed?
  end

  # หาสมาชิกอีกคน (สำหรับ peer chat)
  def other_member(user)
    members.where.not(id: user.id).first
  end
end
