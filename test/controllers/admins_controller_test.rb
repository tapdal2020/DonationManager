require 'test_helper'

class AdminsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "create admin" do
    main_admin = admins(:one)

    post sessions_url, params: { "user" => { email: main_admin.email, password: 'admin' } }

    admin_params = { email: "newadmin@admin.com", password: "admin", password_confirmation: "admin" }
    
    assert_difference('Admin.count', 1, "Should create admin with all parameters") { post admins_url, params: { "admin" => admin_params } }
  end

  test "fail to access create admin as user" do
    user = users(:three)

    post sessions_url, params: { "user" => { email: user.email, password: 'user' } }

    admin_params = { email: "newadmin2@admin.com", password: "admin", password_confirmation: "admin" }

    assert_no_difference('Admin.count', 'should not change admin count when user is not logged in as admin') { post admins_url, params: { "admin" => admin_params } }
    assert_redirected_to(new_session_url, "Should go back to login page")
  end

  [:email, :password, :password_confirmation].each do |item|
    test "fail without #{item}" do
      main_admin = admins(:one)

      post sessions_url, params: { "user" => { email: main_admin.email, password: 'admin' } }

      admin_params = { email: "test@test.com", password: "mypass", password_confirmation: "mypass" }
      admin_params[item] = nil  

      assert_no_difference('Admin.count', "Should fail to create when #{item} is not present") { post admins_url, params: { "admin" => admin_params } }
    end
  end

end
