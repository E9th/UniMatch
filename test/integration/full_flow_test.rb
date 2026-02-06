require "test_helper"

class FullFlowTest < ActionDispatch::IntegrationTest
  # ==================== Complete User Journey ====================

  test "full loop: register -> profile -> dashboard -> match -> chat -> message -> AI -> logout -> login" do
    # 1) Visit home page
    get root_path
    assert_response :success

    # 2) Register a new user
    post register_path, params: {
      user: {
        name: "ทดสอบ ฟูลลูป",
        email: "fullloop@test.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to edit_profile_path
    follow_redirect!
    assert_response :success

    # 3) Fill in profile
    patch update_profile_path, params: {
      user: {
        faculty: "วิศวกรรมศาสตร์",
        strong_subject: "ฟิสิกส์",
        weak_subject: "ภาษาอังกฤษ",
        study_style: "ทำโจทย์ด้วยกัน",
        available_time: "เย็น (16:00-20:00)",
        bio: "ทดสอบ full loop"
      }
    }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success

    # 4) View dashboard (should show matches)
    get dashboard_path
    assert_response :success

    # 5) View matches page
    get matches_path
    assert_response :success

    # 6) Start chat with somying (strong=ภาษาอังกฤษ matches our weak)
    somying = users(:somying)
    post start_chat_match_path(somying)
    assert_response :redirect
    chat_room = ChatRoom.order(:created_at).last
    follow_redirect!
    assert_response :success

    # 7) Send a message
    post chat_room_messages_path(chat_room), params: { message: { content: "สวัสดีครับ!" } }

    # 8) View chat rooms list
    get chat_rooms_path
    assert_response :success

    # 9) Create AI chat room
    post create_ai_chat_path
    assert_response :redirect
    ai_room = ChatRoom.where(is_ai_mode: true).order(:created_at).last
    follow_redirect!
    assert_response :success

    # 10) Send message in AI room
    post chat_room_messages_path(ai_room), params: { message: { content: "ช่วยอธิบายฟิสิกส์" } }

    # 11) Logout
    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success

    # 12) Login again
    post login_path, params: { email: "fullloop@test.com", password: "password123" }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
  end

  # ==================== Login + Browse Flow ====================

  test "login and browse all pages" do
    somchai = users(:somchai)

    # Login
    post login_path, params: { email: somchai.email, password: "password123" }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success

    # Dashboard
    get dashboard_path
    assert_response :success

    # Profile
    get edit_profile_path
    assert_response :success

    # Matches
    get matches_path
    assert_response :success

    # Chat rooms list
    get chat_rooms_path
    assert_response :success

    # View existing chat room
    get chat_room_path(chat_rooms(:human_room))
    assert_response :success

    # AI chat room
    get chat_room_path(chat_rooms(:ai_room))
    assert_response :success

    # Logout
    delete logout_path
    assert_redirected_to root_path
  end

  # ==================== Authorization ====================

  test "all protected pages redirect unauthenticated users to login" do
    protected_paths = [
      dashboard_path,
      edit_profile_path,
      matches_path,
      chat_rooms_path,
      chat_room_path(chat_rooms(:human_room))
    ]

    protected_paths.each do |path|
      get path
      assert_redirected_to login_path, "Expected #{path} to redirect to login"
    end

    # POST actions
    post create_ai_chat_path
    assert_redirected_to login_path

    post start_chat_match_path(users(:somying))
    assert_redirected_to login_path

    post chat_room_messages_path(chat_rooms(:human_room)), params: { message: { content: "hack" } }
    assert_redirected_to login_path
  end

  # ==================== Access Control ====================

  test "non-member cannot access chat room" do
    sign_in_as(users(:kitti))
    get chat_room_path(chat_rooms(:human_room))
    assert_redirected_to chat_rooms_path
  end

  # ==================== Reciprocal Matching ====================

  test "somying sees somchai as match" do
    sign_in_as(users(:somying))
    get matches_path
    assert_response :success
    # somying weak=คณิตศาสตร์ → somchai strong=คณิตศาสตร์ (shown anonymously)
    assert_match(/คณิตศาสตร์/, response.body)
  end
end
