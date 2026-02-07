class Review < ApplicationRecord
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"
  belongs_to :chat_room

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :reviewer_id, uniqueness: { scope: :chat_room_id, message: "ให้คะแนนไปแล้วสำหรับห้องแชทนี้" }
  validate :cannot_review_self

  private

  def cannot_review_self
    if reviewer_id == reviewee_id
      errors.add(:base, "ไม่สามารถรีวิวตัวเองได้")
    end
  end
end
