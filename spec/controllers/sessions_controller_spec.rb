require "rails_helper"

RSpec.describe SessionsController do
    fixtures :users

    describe 'POST create' do
        context 'given existing user attempting to login' do
            before do
                @user = users(:two)
                @session_params = { email: @user.email, password: 'user' }
            end

            it 'should successfully login' do
                post :create, params: { "user" => @session_params }
                expect(session[:user_id]).to be(@user.id) 
            end

            it 'should fail to login' do
                @session_params[:password] = 'wrong'

                post :create, params: { "user" => 
                @session_params }
                expect(session[:user_id]).to be(nil) 
            end
        end

        context 'given existing admin attempting to login' do
            before do
                @user = users(:three)
                @session_params = { email: @user.email, password: 'user' }
            end

            it 'should successfully login' do
                post :create, params: { "user" => @session_params }
                expect(session[:user_id]).to be(@user.id) 
            end

            it 'should fail to login' do
                @session_params[:password] = 'wrong'

                post :create, params: { "user" => @session_params }
                expect(session[:user_id]).to be(nil) 
            end
        end

        context 'given a nonexistent user attempting to login' do
            it 'should fail to login' do
                @session_params = { email: 'idontexist@email.com', password: 'nope' }

                post :create, params: { "user" => @session_params }
                expect(session[:user_id]).to be(nil)
            end
        end
    end

    describe 'DELETE destroy' do
        it 'should redirect to login when no user is logged in' do
            delete :destroy, params: { "id" => 0 }

            expect(response).to redirect_to(new_session_path)
            expect(session[:user_id]).to be(nil)
            expect(session[:last_access]).to be(nil)
        end

        context 'when a current user is logged in' do
            before do
                @user = users(:two)
                @session_params = { email: @user.email, password: 'user' }
                post :create, params: { "user" => @session_params }
            end

            it 'should remove session user_id if a user is logged in' do
                delete :destroy, params: { "id" => @user.id }

                expect(session[:user_id]).to be(nil)
            end

            it 'should remove session last_access if a user is logged in' do
                delete :destroy, params: { "id" => @user.id }

                expect(session[:last_access]).to be(nil)
            end
        end
    end
end
