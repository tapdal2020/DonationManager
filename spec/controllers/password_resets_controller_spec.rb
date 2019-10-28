require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  fixtures :users

  def get_password_reset
    user = users(:two)
    post :create, params: { email: user.email }
    user.reload
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders the new template' do
      get :new
      expect(subject).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'should assign user and redirect to new_session_path when a valid email is provided' do
      post :create, params: { :email => users(:two).email }
      instance_user = @controller.instance_variable_get(:@user)
      expect(instance_user.id).to eq(users(:two).id)
      expect(response).to redirect_to(new_session_path)
    end

    it 'should not assign user when an invalid email is provided' do
      post :create, params: { :email => 'bad@bad.com' }
      expect(@controller.instance_variable_get(:@user)).to be(nil)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET #edit' do
    before do
      @user = get_password_reset
      @reset_token = @user.password_reset_token
    end

    it 'should assign user from a valid reset token' do
      get :edit, params: { id: @reset_token }
      expect(@controller.instance_variable_get(:@user)).to eq(@user)
    end

    it 'should not assign user from invalid reset token' do
      expect { get :edit, params: { id: 0 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'PUT #update' do
    before do
      @user = get_password_reset
      @reset_token = @user.password_reset_token
    end

    it 'should update a password on recent update link' do
      put :update, params: { id: @reset_token, user: { password: 'newpass', password_confirmation: 'newpass' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'should not allow reset on old update links' do
      invalid_time = Time.zone.now + 5.hours
      allow(Time).to receive(:now).and_return(invalid_time)

      put :update, params: { id: @reset_token }
      expect(response).to redirect_to(new_password_reset_path)
    end
  end

end
