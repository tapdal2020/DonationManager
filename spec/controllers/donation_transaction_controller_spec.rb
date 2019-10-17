require 'rails_helper'

RSpec.describe DonationTransactionController do
  fixtures :users

  describe 'GET index' do
    before do
      old_controller = @controller
      @controller = SessionsController.new
      post :create, params: { "user" => { email: users(:two).email, password: 'user' } }
      @controller = old_controller
    end

    it 'should redirect to new_donation_transaction_path' do   
      get :index
      expect(response).to redirect_to(new_donation_transaction_path)
    end
  end

end
