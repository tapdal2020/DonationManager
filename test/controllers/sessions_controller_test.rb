require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "successful user login" do
    user = User.new({ first_name: "New", last_name: "User", email: "test@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", city: "Austin", state: "TX", zip_code: "78726" })
    user.save

    session_params = { email: user.email, password: user.password }

    post sessions_url, params: { "user" => session_params }
    assert_equal(user.id, session[:user_id])
  end

  test "failed user login" do
    user = User.new({ first_name: "New", last_name: "User", email: "test@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", city: "Austin", state: "TX", zip_code: "78726" })
    user.save

    session_params = { email: user.email, password: "wrong#{user.password}" }

    post sessions_url, params: { "user" => session_params }
    assert_not_equal(user.id, session[:user_id])
  end

  test "successful admin login" do
    admin = users(:three)

    session_params = { email: admin.email, password: 'user' }

    post sessions_url, params: { "user" => session_params }
    assert_equal(admin.id, session[:user_id])
  end

  test "failed admin login" do
    admin = users(:three)

    session_params = { email: admin.email, password: "notmypassword" }

    post sessions_url, params: { "user" => session_params }
    assert_not_equal(admin.id, session[:user_id])
  end

end
