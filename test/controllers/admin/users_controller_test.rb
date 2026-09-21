require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "non-master users are redirected" do
    sign_in_as(users(:one))

    get admin_users_url
    assert_redirected_to root_url
  end

  test "master can approve a pending user" do
    sign_in_as(users(:admin))

    patch admin_user_url(users(:pending)), params: { user: { approved: true } }

    assert_redirected_to admin_users_url
    assert users(:pending).reload.approved?
  end

  test "master accounts cannot be revoked" do
    sign_in_as(users(:admin))

    patch admin_user_url(users(:admin)), params: { user: { approved: false } }

    assert_redirected_to admin_users_url
    assert users(:admin).reload.approved?
  end

  test "revoking a user ends their signed-in session" do
    member = users(:two)
    sign_in_as(member)
    get orders_url
    assert_response :success

    sign_in_as(users(:admin))
    patch admin_user_url(member), params: { user: { approved: false } }
    assert_not member.reload.approved?
    assert_empty member.sessions

    sign_in_as(member) # restores the member's cookie, but the account is unapproved
    get orders_url
    assert_redirected_to new_session_url
  end
end
