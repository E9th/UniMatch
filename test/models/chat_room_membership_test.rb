require "test_helper"

class ChatRoomMembershipTest < ActiveSupport::TestCase
  setup do
    @somchai = users(:somchai)
    @kitti   = users(:kitti)
    @human_room = chat_rooms(:human_room)
  end

  test "valid membership" do
    room = ChatRoom.create!(name: "New Room", user: @somchai)
    membership = ChatRoomMembership.new(user: @kitti, chat_room: room)
    assert membership.valid?
  end

  test "prevents duplicate user in same room" do
    dup = ChatRoomMembership.new(user: @somchai, chat_room: @human_room)
    assert_not dup.valid?
    assert dup.errors[:user_id].any?
  end

  test "same user can be in different rooms" do
    room2 = ChatRoom.create!(name: "Room2", user: @somchai)
    membership = ChatRoomMembership.new(user: @somchai, chat_room: room2)
    assert membership.valid?
  end

  test "belongs to user" do
    membership = chat_room_memberships(:somchai_in_human)
    assert_equal @somchai, membership.user
  end

  test "belongs to chat_room" do
    membership = chat_room_memberships(:somchai_in_human)
    assert_equal @human_room, membership.chat_room
  end
end
