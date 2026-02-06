require "test_helper"

class ChatRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai    = users(:somchai)
    @somying    = users(:somying)
    @kitti      = users(:kitti)
    @human_room = chat_rooms(:human_room)
    @ai_room    = chat_rooms(:ai_room)
  end

  # ==================== Index ====================

  test "index requires login" do
    get chat_rooms_path
    assert_redirected_to login_path
  end

  test "index loads when logged in" do
    sign_in_as(@somchai)
    get chat_rooms_path
    assert_response :success
  end

  test "index shows user's chat rooms" do
    sign_in_as(@somchai)
    get chat_rooms_path
    assert_response :success
    # Chat list shows anonymous name "เพื่อนติวปริศนา" for human rooms
    assert_match(/เพื่อนติวปริศนา/, response.body)
  end

  # ==================== Show ====================

  test "show requires login" do
    get chat_room_path(@human_room)
    assert_redirected_to login_path
  end

  test "show loads for member" do
    sign_in_as(@somchai)
    get chat_room_path(@human_room)
    assert_response :success
  end

  test "show loads for second member" do
    sign_in_as(@somying)
    get chat_room_path(@human_room)
    assert_response :success
  end

  test "show redirects non-member" do
    sign_in_as(@kitti)
    get chat_room_path(@human_room)
    assert_redirected_to chat_rooms_path
  end

  test "show AI room for owner" do
    sign_in_as(@somchai)
    get chat_room_path(@ai_room)
    assert_response :success
  end

  test "show AI room blocks non-owner" do
    sign_in_as(@kitti)
    get chat_room_path(@ai_room)
    assert_redirected_to chat_rooms_path
  end

  test "show displays existing messages" do
    sign_in_as(@somchai)
    get chat_room_path(@human_room)
    assert_response :success
    assert_match(/สวัสดีครับ/, response.body)
  end

  # ==================== Create AI Room ====================

  test "create AI room requires login" do
    post create_ai_chat_path
    assert_redirected_to login_path
  end

  test "create AI room creates new room" do
    new_user = User.create!(name: "AITestUser", email: "aitest@test.com", password: "password123")
    sign_in_as(new_user)

    assert_difference("ChatRoom.count", 1) do
      post create_ai_chat_path
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "create AI room is idempotent" do
    sign_in_as(@somchai)
    # somchai already has ai_room from fixtures
    assert_no_difference("ChatRoom.count") do
      post create_ai_chat_path
    end
    assert_redirected_to chat_room_path(@ai_room)
  end

  test "create AI room adds membership" do
    new_user = User.create!(name: "MemberTest", email: "member@test.com", password: "password123")
    sign_in_as(new_user)

    assert_difference("ChatRoomMembership.count", 1) do
      post create_ai_chat_path
    end
  end
end
