require "rails_helper"

RSpec.describe UsersController do
    fixtures :users


    describe 'GET new' do
        it 'should assign @user' do
            get :new
            expect(assigns(:user)).to be_a_new(User)
        end
    end

    describe 'POST create' do
        let(:user_params) { { first_name: "New", last_name: "User", email: "testa@test.com", password: "mypass", password_confirmation: "mypass", street_address_line_1: "Home", city: "Austin", state: "TX", zip_code: "78726" } }

        context 'given all arguments except admin' do
            it 'should create a new user' do

                expect { post :create, params: { "user" => user_params } }.to change(User, :count).by(1)
            end
        end

        [:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code].each do |item|
            it "should fail to create a new user without #{item}" do
                incomplete_params = user_params
                incomplete_params[item] = nil

                expect { post :create, params: { "user" => incomplete_params } }.to change(User, :count).by(0)
            end
        end

        context 'given street_address_line_2 but not street_address_line_1' do
            it 'should fail to create a new user' do
                incomplete_params = user_params
                incomplete_params[:street_address_line_2] = incomplete_params[:street_address_line_1]
                incomplete_params[:street_address_line_1] = nil

                expect { post :create, params: { "user" => incomplete_params } }.to change(User, :count).by(0)
            end
        end

        context 'given an existing admin user is logged in' do
            let(:admin_params) { { email: "newadmin@admin.com", password: "admin", password_confirmation: "admin", admin: true } }
            before do
                main_admin = users(:three)
                old_controller = @controller
                @controller = SessionsController.new
                post :create, params: { "user" => { email: main_admin.email, password: 'user' } }
                @controller = old_controller
            end

            it 'should create a new admin with only the required arguments' do
                expect { post :create, params: { "user" => admin_params } }.to change(User, :count).by(1)
            end

            [:email, :password, :password_confirmation].each do |item|
                it "should fail to create a new admin without #{item}" do
                    incomplete_params = admin_params
                    incomplete_params[item] = nil
    
                    expect { post :create, params: { "user" => incomplete_params } }.to change(User, :count).by(0)
                end
            end
        end
    end

    describe 'Session Expiry' do
        before do
            @user = users(:two)
            old_controller = @controller
            @controller = SessionsController.new
            post :create, params: { "user" => { email: @user.email, password: 'user' } }
            @controller = old_controller
            @time = Time.now
        end

        it 'should reject actions outside session time limit' do
            invalid_time = @time + 5.hours
            allow(Time).to receive(:now).and_return(invalid_time)
            
            get :show, params: { id: @user.id }
            expect(response).to redirect_to(new_session_path)
        end
    end

    describe 'Remember Me' do
        before do
            @user = users(:two)
            old_controller = @controller
            @controller = SessionsController.new
            post :create, params: { "user" => { email: @user.email, password: 'user', rememberme: true } }
            @controller = old_controller
            @time = Time.now
        end

        it 'should accept actions outside session time limit if remember me was checked on login' do
            invalid_time = @time + 5.hours
            allow(Time).to receive(:now).and_return(invalid_time)
            
            get :show, params: { id: @user.id }
            expect(response).not_to redirect_to(new_session_path)
        end
    end
end