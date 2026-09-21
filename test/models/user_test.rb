require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "rejects passwords shorter than 8 characters" do
    user = User.new(email_address: "short@example.com", password: "short", password_confirmation: "short")

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "accepts passwords of 8 characters" do
    user = User.new(email_address: "ok@example.com", password: "password", password_confirmation: "password")

    assert user.valid?
  end

  test "does not require a password when updating other attributes" do
    assert users(:one).update(approved: true)
  end

  test "first user is not automatically approved or master" do
    User.destroy_all
    user = User.create!(email_address: "first@example.com", password: "password")

    assert_not user.approved?
    assert_not user.master?
  end

  test "revoking approval ends existing sessions" do
    user = users(:one)
    user.sessions.create!

    assert_difference -> { user.sessions.count }, -user.sessions.count do
      user.update!(approved: false)
    end
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end
end
