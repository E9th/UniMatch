require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai = users(:somchai)
    @somying = users(:somying)
    @kitti   = users(:kitti)
  end

  test "matches index requires login" do
    get matches_path
    assert_redirected_to login_path
  end

  test "matches index loads" do
    sign_in_as(@somchai)
    get matches_path
    assert_response :success
  end

  test "matches shows correct match for somchai" do
    sign_in_as(@somchai)
    get matches_path
    assert_response :success
    # Match card shows faculty-based anonymous label and skill info
    assert_match(/ภาษาอังกฤษ/, response.body)
  end

  test "start chat requires login" do
    post start_chat_match_path(@somying)
    assert_redirected_to login_path
  end

  test "start chat creates new room with match" do
    sign_in_as(@somchai)
    # Create fresh user to ensure no existing room
    new_match = User.create!(name: "FreshMatch", email: "fresh@test.com", password: "password123",
                             strong_subject: "ภาษาอังกฤษ", weak_subject: "คณิตศาสตร์")
    assert_difference("ChatRoom.count", 1) do
      post start_chat_match_path(new_match)
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "start chat reuses existing room" do
    sign_in_as(@somchai)
    # somchai and somying already share human_room
    assert_no_difference("ChatRoom.count") do
      post start_chat_match_path(@somying)
    end
    assert_redirected_to chat_room_path(chat_rooms(:human_room))
  end

  test "icebreaker requires login" do
    post icebreaker_match_path(@somying)
    assert_redirected_to login_path
  end

  test "icebreaker html format redirects" do
    sign_in_as(@somchai)
    post icebreaker_match_path(@somying)
    assert_redirected_to matches_path
  end

  test "icebreaker json format returns suggestion" do
    sign_in_as(@somchai)
    post icebreaker_match_path(@somying), headers: { "Accept" => "application/json" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("message")
    # The AI may return a fallback error message if no API key is set
    assert_not_nil json["message"]
  end
end
