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
end
