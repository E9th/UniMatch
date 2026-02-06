require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai = users(:somchai)
  end

  test "login page loads" do
    get login_path
    assert_response :success
  end

  test "login page redirects if already logged in" do
    sign_in_as(@somchai)
    get login_path
    assert_redirected_to dashboard_path
  end

  test "successful login redirects to dashboard" do
    post login_path, params: { email: @somchai.email, password: "password123" }
    assert_redirected_to dashboard_path
  end

  test "successful login sets session" do
    post login_path, params: { email: @somchai.email, password: "password123" }
    follow_redirect!
    assert_response :success
    # Should be able to access protected pages
    get dashboard_path
    assert_response :success
  end

  test "login with wrong email returns 422" do
    post login_path, params: { email: "nonexistent@test.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "login with wrong password returns 422" do
    post login_path, params: { email: @somchai.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "login with case-insensitive email" do
    post login_path, params: { email: @somchai.email.upcase, password: "password123" }
    assert_redirected_to dashboard_path
  end

  test "logout clears session" do
    sign_in_as(@somchai)
    delete logout_path
    assert_redirected_to root_path
    # Should NOT be able to access protected pages after logout
    get dashboard_path
    assert_redirected_to login_path
  end
end
