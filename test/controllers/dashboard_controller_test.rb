require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "dashboard requires login" do
    get dashboard_path
    assert_redirected_to login_path
  end

  test "dashboard loads when logged in" do
    sign_in_as(users(:somchai))
    get dashboard_path
    assert_response :success
  end

  test "dashboard shows match results" do
    sign_in_as(users(:somchai))
    get dashboard_path
    assert_response :success
    # Dashboard shows anonymous name for matches
    assert_match(/เพื่อนติวปริศนา/, response.body)
  end

  test "dashboard shows chat rooms" do
    sign_in_as(users(:somchai))
    get dashboard_path
    assert_response :success
    # Dashboard shows chat room count
    assert_match(/ห้องแชท/, response.body)
  end
end
