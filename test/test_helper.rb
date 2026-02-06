ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # SQLite does not support concurrent writes, so use single thread for tests
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  # Helper to sign in a user for controller/integration tests
  def sign_in_as(user, password: "password123")
    post login_path, params: { email: user.email, password: password }
  end
end
