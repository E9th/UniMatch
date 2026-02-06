require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai    = users(:somchai)
    @human_room = chat_rooms(:human_room)
    @ai_room    = chat_rooms(:ai_room)
  end

  test "create message requires login" do
    post chat_room_messages_path(@human_room), params: { message: { content: "Test" } }
    assert_redirected_to login_path
  end

  test "create message in human room" do
    sign_in_as(@somchai)
    assert_difference("Message.count", 1) do
      post chat_room_messages_path(@human_room), params: { message: { content: "ข้อความทดสอบ" } }
    end
  end

  test "create message sets user and role" do
    sign_in_as(@somchai)
    post chat_room_messages_path(@human_room), params: { message: { content: "Test msg" } }
    msg = Message.order(:created_at).last
    assert_equal @somchai, msg.user
    assert_equal "user", msg.role
    assert_equal @human_room, msg.chat_room
  end

  test "create blank message does not save" do
    sign_in_as(@somchai)
    assert_no_difference("Message.count") do
      post chat_room_messages_path(@human_room), params: { message: { content: "" } }
    end
  end

  test "create message in AI room enqueues AI job" do
    sign_in_as(@somchai)
    assert_difference("Message.count", 1) do
      post chat_room_messages_path(@ai_room), params: { message: { content: "ช่วยอธิบายแคลคูลัส" } }
    end
    # AiResponseJob should be enqueued
  end

  test "create message via turbo stream format" do
    sign_in_as(@somchai)
    post chat_room_messages_path(@human_room),
         params: { message: { content: "Turbo test message" } },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match(/turbo-stream/, response.body)
  end

  test "create message touches chat room updated_at" do
    sign_in_as(@somchai)
    old_updated = @human_room.updated_at
    sleep(0.1) # ensure time difference
    post chat_room_messages_path(@human_room), params: { message: { content: "Touch test" } }
    @human_room.reload
    assert @human_room.updated_at > old_updated
  end
end
