require "test_helper"

class AiResponseJobTest < ActiveJob::TestCase
  setup do
    @somchai = users(:somchai)
    @ai_room = chat_rooms(:ai_room)
  end

  test "creates AI response message after user message" do
    # Create user message in AI room
    user_msg = Message.create!(
      content: "ช่วยอธิบายแคลคูลัส",
      user: @somchai,
      chat_room: @ai_room,
      role: "user"
    )

    # Run job - API will fail (no key) but rescue creates fallback message
    assert_difference("Message.count", 1) do
      AiResponseJob.perform_now(user_msg.id)
    end

    ai_msg = Message.order(:created_at).last
    assert_equal "assistant", ai_msg.role
    assert_equal @ai_room, ai_msg.chat_room
    assert_nil ai_msg.user  # AI messages have no user
    assert ai_msg.content.present?
  end

  test "AI response message is associated with correct room" do
    user_msg = Message.create!(
      content: "สอนฟิสิกส์หน่อย",
      user: @somchai,
      chat_room: @ai_room,
      role: "user"
    )

    AiResponseJob.perform_now(user_msg.id)
    ai_msg = Message.where(role: "assistant", chat_room: @ai_room).order(:created_at).last
    assert_not_nil ai_msg
    assert_equal @ai_room.id, ai_msg.chat_room_id
  end

  test "job handles missing message gracefully" do
    assert_raises(ActiveRecord::RecordNotFound) do
      AiResponseJob.perform_now(-999)
    end
  end
end
