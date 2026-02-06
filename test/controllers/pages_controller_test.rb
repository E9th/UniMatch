require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page loads for visitors" do
    get root_path
    assert_response :success
  end

  test "home page redirects to dashboard when logged in" do
    sign_in_as(users(:somchai))
    get root_path
    assert_redirected_to dashboard_path
  end
end
