require "test_helper"

class ChatRoomTest < ActiveSupport::TestCase
  setup do
    @human_room = chat_rooms(:human_room)
    @ai_room    = chat_rooms(:ai_room)
    @somchai    = users(:somchai)
  end

  # ==================== Validations ====================

  test "valid chat room" do
    room = ChatRoom.new(name: "Test Room", user: @somchai)
    assert room.valid?
  end

  test "requires name" do
    room = ChatRoom.new(user: @somchai)
    assert_not room.valid?
    assert room.errors[:name].any?
  end

  # ==================== is_ai_mode? ====================

  test "is_ai_mode? true for AI room" do
    assert @ai_room.is_ai_mode?
  end

  test "is_ai_mode? false for human room" do
    assert_not @human_room.is_ai_mode?
  end

  # ==================== last_message ====================

  test "last_message returns a message from the room" do
    msg = @human_room.last_message
    assert_not_nil msg
    assert_equal @human_room, msg.chat_room
  end

  test "last_message returns nil when no messages" do
    room = ChatRoom.create!(name: "Empty", user: @somchai)
    assert_nil room.last_message
  end

  test "last_message returns the newest message" do
    old = Message.create!(content: "Old", user: @somchai, chat_room: @human_room, role: "user", created_at: 1.hour.ago)
    new_msg = Message.create!(content: "New", user: @somchai, chat_room: @human_room, role: "user", created_at: Time.current)
    assert_equal new_msg, @human_room.last_message
  end

  # ==================== Associations ====================

  test "has many members" do
    assert_includes @human_room.members, @somchai
    assert_includes @human_room.members, users(:somying)
  end

  test "has many messages" do
    assert @human_room.messages.count >= 2
  end

  test "has many memberships" do
    assert @human_room.chat_room_memberships.count >= 2
  end

  test "destroying room destroys messages" do
    room = ChatRoom.create!(name: "Temp", user: @somchai)
    ChatRoomMembership.create!(user: @somchai, chat_room: room)
    Message.create!(content: "will be deleted", user: @somchai, chat_room: room, role: "user")
    assert_difference("Message.count", -1) do
      room.destroy
    end
  end

  test "destroying room destroys memberships" do
    room = ChatRoom.create!(name: "Temp", user: @somchai)
    ChatRoomMembership.create!(user: @somchai, chat_room: room)
    assert_difference("ChatRoomMembership.count", -1) do
      room.destroy
    end
  end
end
