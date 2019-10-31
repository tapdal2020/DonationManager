require 'rails_helper'

RSpec.describe DonationTransactionController do
  fixtures :users
  fixtures :made_donations
  def login_user 
      @user = users(:two)
      old_controller = @controller
      @controller = SessionsController.new
      post :create, params: { "user" => { email: @user.email, password: 'user' } }
      @controller = old_controller
      @user
  end

  describe 'Get index' do
    it 'should redirect user ' do
      get :index
      expect(redirect_to(new_donation_transaction_path))
    end
  end

  describe 'GET new' do
    context 'given a non-existing user' do
      it 'should determine where params should be directed to ' do
          get :new
          expect(redirect_to(new_donation_transaction_path))
      end
    end

    context 'given a existing user' do
      before do
        @user = login_user
      end
      it 'should create @donation as new ' do
          get :new, params: { "user" => { email: @user.email, password: 'user' } }
          expect(assigns(:donation)).to be_a_new(MadeDonation)
      end
    end

    context 'given `paymentId, payerID, token` returned from PayPal' do
    end

    context 'given only `token` returned from PayPal' do
    end

  end

end
