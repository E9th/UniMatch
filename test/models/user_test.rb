require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @somchai = users(:somchai)
    @somying = users(:somying)
    @kitti = users(:kitti)
  end

  # ==================== Validations ====================

  test "valid user can be created" do
    user = User.new(name: "Test User", email: "valid@example.com", password: "password123")
    assert user.valid?, "User should be valid: #{user.errors.full_messages}"
  end

  test "requires name" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:name].any?
  end

  test "requires email" do
    user = User.new(name: "Test", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "requires unique email (case insensitive)" do
    user = User.new(name: "Dup", email: @somchai.email.upcase, password: "password123")
    assert_not user.valid?
  end

  test "rejects invalid email format" do
    invalid_emails = ["notanemail", "missing@", "@nodomain.com", "spaces in@email.com"]
    invalid_emails.each do |bad_email|
      user = User.new(name: "Test", email: bad_email, password: "password123")
      assert_not user.valid?, "#{bad_email} should be invalid"
    end
  end

  test "requires password minimum 6 characters" do
    user = User.new(name: "Test", email: "short@test.com", password: "12345")
    assert_not user.valid?
  end

  test "accepts password with 6+ characters" do
    user = User.new(name: "Test", email: "ok@test.com", password: "123456")
    assert user.valid?
  end

  # ==================== Authentication ====================

  test "authenticates with correct password" do
    assert @somchai.authenticate("password123")
  end

  test "rejects wrong password" do
    assert_not @somchai.authenticate("wrongpassword")
  end

  # ==================== Scopes ====================

  test "except_user excludes given user" do
    result = User.except_user(@somchai)
    assert_not_includes result, @somchai
    assert_includes result, @somying
    assert_includes result, @kitti
  end

  test "strong_in filters by strong_subject" do
    result = User.strong_in("ภาษาอังกฤษ")
    assert_includes result, @somying
    assert_not_includes result, @somchai
    assert_not_includes result, @kitti
  end

  test "same_study_style filters by study_style" do
    result = User.same_study_style("ทำโจทย์ด้วยกัน")
    assert_includes result, @somchai
    assert_not_includes result, @somying
  end

  test "same_available_time filters by available_time" do
    result = User.same_available_time("เย็น (16:00-20:00)")
    assert_includes result, @somchai
    assert_includes result, @somying
    assert_not_includes result, @kitti
  end

  # ==================== find_matches ====================

  test "find_matches returns users strong in my weak subject" do
    # somchai weak=ภาษาอังกฤษ → somying strong=ภาษาอังกฤษ
    matches = @somchai.find_matches
    assert_includes matches, @somying
    assert_not_includes matches, @kitti
  end

  test "find_matches excludes self" do
    matches = @somchai.find_matches
    assert_not_includes matches, @somchai
  end

  test "find_matches returns all others when no weak_subject set" do
    user = User.create!(name: "NoWeak", email: "noweak@test.com", password: "password123")
    matches = user.find_matches
    assert_includes matches, @somchai
    assert_includes matches, @somying
    assert_includes matches, @kitti
  end

  test "find_matches reciprocal: somying finds somchai" do
    # somying weak=คณิตศาสตร์ → somchai strong=คณิตศาสตร์
    matches = @somying.find_matches
    assert_includes matches, @somchai
  end

  # ==================== ai_chat_room ====================

  test "ai_chat_room creates new AI room for user" do
    user = User.create!(name: "AIUser", email: "aiuser@test.com", password: "password123")
    room = user.ai_chat_room
    assert room.persisted?
    assert room.is_ai_mode?
    assert_equal user, room.user
    assert_includes room.name, user.name
  end

  test "ai_chat_room returns same room on repeated calls" do
    room1 = @somchai.ai_chat_room
    room2 = @somchai.ai_chat_room
    assert_equal room1.id, room2.id
  end

  # ==================== Associations ====================

  test "has many messages" do
    assert_respond_to @somchai, :messages
    assert @somchai.messages.count >= 1
  end

  test "has many chat_rooms through memberships" do
    assert_respond_to @somchai, :chat_rooms
    assert_includes @somchai.chat_rooms, chat_rooms(:human_room)
  end

  test "has many owned_chat_rooms" do
    assert_respond_to @somchai, :owned_chat_rooms
  end

  test "destroying user destroys associated messages" do
    user = User.create!(name: "DeleteMe", email: "delete@test.com", password: "password123")
    room = ChatRoom.create!(name: "TempRoom", user: user)
    ChatRoomMembership.create!(user: user, chat_room: room)
    Message.create!(content: "temp", user: user, chat_room: room, role: "user")

    assert_difference("Message.count", -1) do
      user.destroy
    end
  end
end
