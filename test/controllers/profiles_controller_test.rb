require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai = users(:somchai)
  end

  test "edit profile requires login" do
    get edit_profile_path
    assert_redirected_to login_path
  end

  test "edit profile loads when logged in" do
    sign_in_as(@somchai)
    get edit_profile_path
    assert_response :success
  end

  test "update profile successfully" do
    sign_in_as(@somchai)
    patch update_profile_path, params: {
      user: {
        name: "สมชาย อัปเดต",
        faculty: "วิทยาศาสตร์",
        strong_subject: "ฟิสิกส์",
        weak_subject: "เคมี",
        study_style: "เรียนเป็นกลุ่ม",
        available_time: "เช้า (8:00-12:00)",
        bio: "โปรไฟล์อัปเดตแล้ว"
      }
    }
    assert_redirected_to dashboard_path

    @somchai.reload
    assert_equal "สมชาย อัปเดต", @somchai.name
    assert_equal "วิทยาศาสตร์", @somchai.faculty
    assert_equal "ฟิสิกส์", @somchai.strong_subject
    assert_equal "เคมี", @somchai.weak_subject
    assert_equal "เรียนเป็นกลุ่ม", @somchai.study_style
    assert_equal "เช้า (8:00-12:00)", @somchai.available_time
    assert_equal "โปรไฟล์อัปเดตแล้ว", @somchai.bio
  end

  test "update profile with blank name fails" do
    sign_in_as(@somchai)
    patch update_profile_path, params: { user: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "update profile requires login" do
    patch update_profile_path, params: { user: { name: "Hack" } }
    assert_redirected_to login_path
  end

  test "partial profile update preserves other fields" do
    sign_in_as(@somchai)
    original_email = @somchai.email
    patch update_profile_path, params: { user: { bio: "New bio" } }
    assert_redirected_to dashboard_path

    @somchai.reload
    assert_equal "New bio", @somchai.bio
    assert_equal original_email, @somchai.email
  end
end
