require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "creates user" do 
    user_params = { first_name: "New", last_name: "User", email: "testa@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", city: "Austin", state: "TX", zip_code: "78726" }
    user_params[:password] = "fake"
    user_params[:password_confirmation] = "fake"

    assert_difference('User.count', 1, "Should create user with all parameters") { post users_url, params: { "user" => user_params } }
  end

  [:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code].each do |item|
    test "fail without #{item}" do    
      user_params = { first_name: "New", last_name: "User", email: "test@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", city: "Austin", state: "TX", zip_code: "78726" }
      user_params[item] = nil  

      assert_no_difference('User.count', "Should fail to create when #{item} is not present") { post users_url, params: { "user" => user_params } }
    end
  end

  test "fail with street_address_line_2 but not street_address_line 1" do
    user_params = { first_name: "New", last_name: "User", email: "test@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", street_address_line_2: "house", city: "Austin", state: "TX", zip_code: "78726" }
    user_params[:street_address_line_1] = nil

    assert_no_difference('User.count', "Should fail to create when street_address_line_2 is present but line 1 is not") { post users_url, params: { "user" => user_params } }
  end

  test "cannot duplicate email" do
    user_params = { first_name: "New", last_name: "User", email: "jacob@fake.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", street_address_line_2: "house", city: "Austin", state: "TX", zip_code: "78726" }

    assert_no_difference('User.count', "Should fail to create with a duplicated email address") { post users_url, params: { "user" => user_params } }
  end

  test "create admin" do
    main_admin = users(:three)

    post sessions_url, params: { "user" => { email: main_admin.email, password: 'user' } }

    admin_params = { email: "newadmin@admin.com", password: "admin", password_confirmation: "admin", admin: true }
    
    assert_difference('User.count', 1, "Should create admin with all parameters") { post users_url, params: { "user" => admin_params } }
  end

  [:email, :password, :password_confirmation].each do |item|
    test "fail without #{item} for admin" do
      main_admin = users(:three)

      post sessions_url, params: { "user" => { email: main_admin.email, password: 'user' } }

      admin_params = { email: "test@test.com", password: "mypass", password_confirmation: "mypass" }
      admin_params[item] = nil  

      assert_no_difference('User.count', "Should fail to create when #{item} is not present") { post users_url, params: { "user" => admin_params } }
    end
  end

end