class User < ApplicationRecord
  has_secure_password

  has_many :messages, dependent: :destroy
  has_many :chat_room_memberships, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_memberships
  has_many :owned_chat_rooms, class_name: "ChatRoom", dependent: :destroy

  # บังคับใช้อีเมลมหาวิทยาลัย
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[\w+\-.]+@.+\..+\z/i, message: "รูปแบบอีเมลไม่ถูกต้อง" }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Scopes สำหรับ Matching
  scope :except_user, ->(user) { where.not(id: user.id) }
  scope :strong_in, ->(subject) { where(strong_subject: subject) }
  scope :same_study_style, ->(style) { where(study_style: style) }
  scope :same_available_time, ->(time) { where(available_time: time) }

  # ค้นหาเพื่อนที่ Match กัน
  def find_matches
    matches = User.except_user(self)

    # เก่งในสิ่งที่เราอ่อน
    matches = matches.strong_in(weak_subject) if weak_subject.present?

    # สไตล์การเรียนเดียวกัน (optional filter)
    # matches = matches.same_study_style(study_style) if study_style.present?

    matches
  end

  # ค้นหาหรือสร้าง AI Chat Room ส่วนตัว
  def ai_chat_room
    owned_chat_rooms.find_or_create_by(is_ai_mode: true) do |room|
      room.name = "AI Assistant - #{name}"
    end
  end
end
