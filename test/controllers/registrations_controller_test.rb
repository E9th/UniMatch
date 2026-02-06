require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "register page loads" do
    get register_path
    assert_response :success
  end

  test "register page redirects if already logged in" do
    sign_in_as(users(:somchai))
    get register_path
    assert_redirected_to dashboard_path
  end

  test "successful registration creates user" do
    assert_difference("User.count", 1) do
      post register_path, params: {
        user: {
          name: "ผู้ใช้ใหม่",
          email: "newuser@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to edit_profile_path
  end

  test "successful registration auto-logs in" do
    post register_path, params: {
      user: {
        name: "AutoLogin",
        email: "autologin@test.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    follow_redirect!
    # Should be able to access edit_profile (protected)
    assert_response :success
  end

  test "registration downcases email" do
    post register_path, params: {
      user: {
        name: "UpperCase",
        email: "UPPER@TEST.COM",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    user = User.find_by(email: "upper@test.com")
    assert_not_nil user
  end

  test "registration fails with blank name" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          name: "",
          email: "blank@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "registration fails with duplicate email" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          name: "Dup",
          email: users(:somchai).email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "registration fails with short password" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          name: "Short",
          email: "short@test.com",
          password: "123",
          password_confirmation: "123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "registration fails with mismatched password confirmation" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          name: "Mismatch",
          email: "mismatch@test.com",
          password: "password123",
          password_confirmation: "different456"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
