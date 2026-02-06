require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @user_msg = messages(:user_message)
    @chat_room = chat_rooms(:human_room)
    @ai_room = chat_rooms(:ai_room)
    @somchai = users(:somchai)
  end

  # ==================== Validations ====================

  test "valid user message" do
    msg = Message.new(content: "Hello", user: @somchai, chat_room: @chat_room, role: "user")
    assert msg.valid?, "Message should be valid: #{msg.errors.full_messages}"
  end

  test "requires content" do
    msg = Message.new(user: @somchai, chat_room: @chat_room, role: "user")
    assert_not msg.valid?
    assert msg.errors[:content].any?
  end

  test "requires valid role" do
    msg = Message.new(content: "Test", user: @somchai, chat_room: @chat_room, role: "invalid_role")
    assert_not msg.valid?
  end

  test "accepts user role" do
    msg = Message.new(content: "Test", user: @somchai, chat_room: @chat_room, role: "user")
    assert msg.valid?
  end

  test "accepts assistant role" do
    msg = Message.new(content: "AI reply", chat_room: @chat_room, role: "assistant")
    assert msg.valid?
  end

  test "default role is user" do
    msg = Message.new
    assert_equal "user", msg.role
  end

  # ==================== AI Messages (CRITICAL: user can be nil) ====================

  test "AI message can be created without user (user: nil)" do
    msg = Message.new(content: "AI response", chat_room: @ai_room, role: "assistant", user: nil)
    assert msg.valid?, "AI message should be valid without user: #{msg.errors.full_messages}"
    assert msg.save, "AI message should save to DB without user: #{msg.errors.full_messages}"
  end

  # ==================== Helpers ====================

  test "from_ai? returns true for assistant" do
    msg = Message.new(role: "assistant")
    assert msg.from_ai?
  end

  test "from_ai? returns false for user" do
    assert_not @user_msg.from_ai?
  end

  test "sender_name for user with name" do
    assert_equal @somchai.name, @user_msg.sender_name
  end

  test "sender_name for AI message" do
    msg = Message.new(role: "assistant")
    assert_equal "AI ติวเตอร์", msg.sender_name
  end

  test "sender_name for message without user" do
    msg = Message.new(role: "user", content: "orphan")
    assert_equal "เพื่อนติว", msg.sender_name
  end

  # ==================== Associations ====================

  test "belongs to chat_room" do
    assert_equal @chat_room, @user_msg.chat_room
  end

  test "belongs to user" do
    assert_equal @somchai, @user_msg.user
  end
end
