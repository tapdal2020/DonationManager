require 'rails_helper'

RSpec.describe ReceiptsController, type: :controller do
    fixtures :users

    def login_user
        user = users(:two)
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: user.email, password: 'user' } }
        @controller = old_controller
        user
    end

    def login_admin
        main_admin = users(:three)
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: main_admin.email, password: 'user' } }
        @controller = old_controller
        main_admin
    end

    describe 'GET index' do
        it 'should not allow access if no user is logged in' do
            get :index, params: { format: :pdf }
            expect(response).to redirect_to(new_session_path)
        end

        context 'given a user is logged in' do
            before do
                @user = login_user
            end

            it 'should get all of the user\'s transactions' do
                get :index, params: { format: :pdf }
                expect(assigns(:donations)).to eq(@user.made_donations)
            end

            it 'should take the user to a pdf page' do
                get :index, params: { format: :pdf }
                expect(response.content_type).to eq("application/pdf") 
            end
        end
    end

end
