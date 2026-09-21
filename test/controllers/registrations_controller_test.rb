require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signup creates an unapproved, non-master user" do
    assert_difference("User.count") do
      post signup_url, params: { user: { email_address: "new@example.com", password: "password", password_confirmation: "password" } }
    end

    user = User.find_by!(email_address: "new@example.com")
    assert_not user.approved?
    assert_not user.master?
    assert_redirected_to new_session_url
  end

  test "signup rejects a short password" do
    assert_no_difference("User.count") do
      post signup_url, params: { user: { email_address: "new@example.com", password: "short", password_confirmation: "short" } }
    end

    assert_response :unprocessable_entity
  end
end
