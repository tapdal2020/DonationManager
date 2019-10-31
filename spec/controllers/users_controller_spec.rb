require "rails_helper"

RSpec.describe UsersController do
    fixtures :users

    def login_user
        @user = users(:two)
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: @user.email, password: 'user' } }
        @controller = old_controller
        @user
    end

    def login_admin
        main_admin = users(:three)
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: main_admin.email, password: 'user' } }
        @controller = old_controller
        main_admin
    end

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

        it 'should fail to create a new user with admin' do
            spoof_params = user_params
            spoof_params[:admin] = true

            expect { post :create, params: { "user" => spoof_params } }.to change(User, :count).by(0)
        end

        context 'given street_address_line_2 but not street_address_line_1' do
            it 'should fail to create a new user' do
                incomplete_params = user_params
                incomplete_params[:street_address_line_2] = incomplete_params[:street_address_line_1]
                incomplete_params[:street_address_line_1] = nil

                expect { post :create, params: { "user" => incomplete_params } }.to change(User, :count).by(0)
            end
        end

        context 'given a user is logged in' do
            it 'should redirect to user(:id)' do
                login_user
                
                post :create, params: { "user" => user_params }
                expect(response).to redirect_to(user_path(session[:user_id]))
            end
        end

        context 'given an existing admin user is logged in' do
            let(:admin_params) { { email: "newadmin@admin.com", password: "admin", password_confirmation: "admin", admin: true } }
            before do
                @main_admin = login_admin
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
            @user = login_user
            @time = Time.now
        end

        it 'should reject actions outside session time limit' do
            invalid_time = @time + 5.hours
            allow(Time).to receive(:now).and_return(invalid_time)
            
            get :show, params: { id: @user.id }
            expect(response).to redirect_to(new_session_path)
        end
    end

    describe 'GET show' do
        it 'should not allow access if no user is logged in' do
            get :show, params: { id: 0 }
            expect(response).to redirect_to(new_session_path)
        end

        context 'given a user is logged in' do
            before do
                @user = login_user
            end

            it 'should allow a user to view their own page' do
                get :show, params: { id: @user.id }
                expect(response).not_to render_template('unauthorized')
                expect(assigns(:html_donation_title)).to eq('Donations Overview')
                expect(assigns(:my_donations)).to eq(@user.made_donations)
            end

            it 'should not allow a user to view another user\'s page' do
                get :show, params: { id: users(:one).id }
                expect(subject).to render_template('unauthorized')
            end
        end

        context 'given an admin is logged in' do
            before do
                @main_admin = login_admin
            end

            it 'should allow an admin to view their page' do
                get :show, params: { id: @main_admin.id }
                expect(response).not_to render_template('unauthorized')
                expect(assigns(:html_donation_title)).to eq('Donation Administrator')
                MadeDonation.all.each do |x|
                    expect(assigns(:my_donations)).to include(x)
                end
            end

            it 'should not allow admins to view user page' do
                get :show, params: { id: users(:one).id }
                expect(subject).to render_template('unauthorized')
            end
        end
    end

    describe 'GET index' do
        it 'should not allow access if no admin is logged in' do
            get :index
            expect(response).to redirect_to(new_session_path)
            
            login_user
            get :index
            expect(response).to redirect_to(new_session_path)
        end

        context 'given an admin is logged in' do
            before do
                @main_admin = login_admin
            end

            it 'should allow an admin to view all the users' do
                get :index
                expect(response).not_to redirect_to(new_session_path)
                User.all.each do |u|
                    expect(assigns(:users)).to include(u)
                end
            end
        end
    end

    describe 'GET edit' do
        it 'should not allow access if no user is logged in' do
            get :edit, params: { id: 0 }
            expect(response).to redirect_to(new_session_path)
        end

        context 'given a user is logged in ' do
            before do
                @user = login_user
            end

            it 'should render edit template if a user is logged in and the user requests to edit themself' do
                get :edit, params: { id: @user.id }
                expect(subject).to render_template(:edit)
            end

            it 'should not render edit template if a user is logged in and the user requests to edit another user' do
                get :edit, params: { id: @user.id + 1 }
                expect(subject).to_not render_template(:edit)
                expect(subject).to render_template('unauthorized')
            end

            it 'should find the current user' do
                get :edit, params: { id: @user.id }
                expect(assigns(:user)).to be_a(User)
            end
        end

        context 'given an admin is logged in' do
            before do
                @main_admin = login_admin
            end

            it 'should render edit template for the admin' do
                get :edit, params: { id: @main_admin.id }
                expect(subject).to render_template(:edit)
            end

            it 'should render edit template for another user' do
                get :edit, params: { id: users(:one).id }
                expect(subject).to render_template(:edit)
            end
        end
    end

    describe 'PUT update' do
        it 'should not allow access if no user is logged in' do
            put :update, params: { id: 0 }
            expect(response).to redirect_to(new_session_path)
        end

        context 'given a user is logged in' do
            before do
                @user = login_user
            end

            it 'should allow the user to update their own information' do
                update_params = { first_name: 'updated', last_name: 'user', email: 'idontexistyet@test.com', street_address_line_1: 'mystreet', city: 'home', state: 'tx', zip_code: '77777', street_address_line_2: 'apt 200' }

                put :update, params: { id: @user.id, "user" => update_params }
                expect(response).to redirect_to(user_path(@user.id))
            end

            it 'should not allow a user to change their own admin status' do
                update_params = { admin: true }

                put :update, params: { id: @user.id, "user" => update_params }
                @user.reload
                expect(@user.admin).to be(false)               
            end

            it 'should not allow duplicate emails' do
                update_params = { email: "jacob@fake.com" }

                put :update, params: { id: @user.id, "user" => update_params }
                expect(subject).to render_template('edit')
            end

            it 'should not allow a user to update another user' do
                update_params = { first_name: 'updated', last_name: 'user', email: 'idontexistyet@test.com', street_address_line_1: 'mystreet', city: 'home', state: 'tx', zip_code: '77777', street_address_line_2: 'apt 200' }

                put :update, params: { id: @user.id + 1, "user" => update_params }
                expect(subject).to render_template('unauthorized')
            end
        end

        context 'given an admin is logged in' do
            before do
                @main_admin = login_admin
            end

            it 'should allow an admin to update themself' do
                update_params = { first_name: 'updated', last_name: 'admin', email: 'idontexistyet@admin.com', street_address_line_1: 'mystreet', city: 'home', state: 'tx', zip_code: '77777', street_address_line_2: 'apt 200' }

                put :update, params: { id: @main_admin.id, "user" => update_params }
                @main_admin.reload

                expect(response).to redirect_to(users_path)
                expect(@main_admin.first_name).to eq('updated')
                expect(@main_admin.last_name).to eq('admin')
            end

            it 'should allow admin to update another user to an admin' do
                update_params = { admin: true }
                @new_admin = users(:one)

                put :update, params: { id: @new_admin.id, "user" => update_params }
                @new_admin.reload

                expect(response).to redirect_to(users_path)
                expect(@new_admin.admin).to be(true)
            end
        end
    end

    describe 'DELETE destroy' do
        it 'should not allow access if no user is logged in' do
            delete :destroy, params: { id: 0 }
            expect(response).to redirect_to(new_session_path)
        end

        context 'given a user is logged in' do
            before do
                @tuser = login_user
            end

            it 'should allow a user to delete themself' do
                expect { delete :destroy, params: { id: @tuser.id } }.to change(User, :count).by(-1)
            end

            it 'should not allow a user to delete another user' do
                expect { delete :destroy, params: { id: users(:one).id } }.to change(User, :count).by(0)
                expect(subject).to render_template('unauthorized')
            end

            it 'should render edit on failure to delete'
        end

        context 'given an admin is logged in' do
            before do
                @main_admin = login_admin
            end

            it 'should allow an admin to delete themself' do
                expect { delete :destroy, params: { id: @main_admin.id } }.to change(User, :count).by(-1)
            end

            it 'should allow an admin to delete another user' do
                expect { delete :destroy, params: { id: users(:one).id } }.to change(User, :count).by(-1)
                expect(subject).to redirect_to(users_path)
            end
        end
    end
    describe 'Remember Me' do
        before do
            @user = users(:two)
            old_controller = @controller
            @controller = SessionsController.new
            post :create, params: { "user" => { email: @user.email, password: 'user', rememberme: 1 } }
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