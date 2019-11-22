require 'rails_helper'

RSpec.describe DonationTransactionsController do
  fixtures :users

  let(:mock_payment) { double('PayPal::SDK::REST::DataTypes::Payment') }

  def login_jacob
    @user = users(:four)
    old_controller = @controller
    @controller = SessionsController.new
    post :create, params: { "user" => { email: @user.email, password: 'user' } }
    @controller = old_controller
    @user
  end

  def login_jane
    @user = users(:five)
    old_controller = @controller
    @controller = SessionsController.new
    post :create, params: { "user" => { email: @user.email, password: 'user' } }
    @controller = old_controller
    @user
  end

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

  describe 'GET new' do
    it 'should redirect if no user is signed in' do
      get :new
      expect(response).to redirect_to(new_session_path)    
    end

    context 'given a user is signed in' do
      before do
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: users(:two).email, password: 'user' } }
        @controller = old_controller
      end

      it 'should assign @donation to be new when there are no params' do
        get :new
        expect(assigns(:donation)).to be_a_new(MadeDonation)
      end

      it 'should call success when token, paymentId, and PayerID are in params' do
        payment = PayPal::SDK::REST::Payment.new
        success_payment = PayPal::SDK::REST::Payment.new(success: true)
        donation = MadeDonation.new
        allow(PayPal::SDK::REST::Payment).to receive(:find).and_return(payment)
        allow(MadeDonation).to receive(:find_by).with(payment_id: "0").and_return(donation)
        allow(@controller).to receive(:execute_paypal_payment).and_return(success_payment)
        
        get :new, params: { token: 0, paymentId: 0, PayerID: 0 }

        expect(assigns(:PayerID)).to eq("0")
        expect(assigns(:transaction)).to eq(donation)
        
        expect(donation.payer_id).to eq("0")
        expect(flash[:alert]).to eq("Donation Succeeded")
      end

      it 'should render something_wrong when it cannot find the transaction' do
        payment = PayPal::SDK::REST::Payment.new
        
        allow(PayPal::SDK::REST::Payment).to receive(:find).and_return(payment)
        allow(MadeDonation).to receive(:find_by).with(payment_id: "0").and_return(nil)
        
        get :new, params: { token: 0, paymentId: 0, PayerID: 0 }
        expect(subject).to render_template('something_wrong')
      end

      it 'should flash an alert when the payment is not a success' do
        payment = PayPal::SDK::REST::Payment.new
        fail_payment = PayPal::SDK::REST::Payment.new
        donation = MadeDonation.new
        allow(PayPal::SDK::REST::Payment).to receive(:find).and_return(payment)
        allow(MadeDonation).to receive(:find_by).with(payment_id: "0").and_return(donation)
        allow(@controller).to receive(:execute_paypal_payment).and_return(fail_payment)
        allow(fail_payment).to receive(:success?).and_return(false)
        
        get :new, params: { token: 0, paymentId: 0, PayerID: 0 }

        expect(assigns(:PayerID)).to eq("0")
        expect(assigns(:transaction)).to eq(donation)
        
        expect(flash[:alert]).to eq(fail_payment.error)
      end

      it 'should call cancelled when only a token is passed' do
        donation = MadeDonation.new
        allow(MadeDonation).to receive(:find_by).with(token: "0").and_return(donation)

        get :new, params: { token: "0" }
        expect(flash[:alert]).to eq("Donation Cancelled")
      end

      it 'should render something wrong when cancelled cannot find the donation' do
        allow(MadeDonation).to receive(:find_by).with(token: "0").and_return(nil)

        get :new, params: { token: "0" }
        expect(subject).to render_template('something_wrong')
      end
    end
  end

  describe 'POST create' do
    it 'should redirect if no user is signed in' do
      post :checkout
      expect(response).to redirect_to(new_session_path)    
    end
    
    context 'given an existing user is signed in' do
      before do
        old_controller = @controller
        @controller = SessionsController.new
        post :create, params: { "user" => { email: users(:two).email, password: 'user' } }
        @controller = old_controller
      end

      it 'should assign values to create ONE-TIME payment' do
        get :checkout, params: { make_donation: { donation_amount: 4, payment_freq: "ONE" } }
        expect(assigns(:user)).not_to be_nil
        expect(assigns(:money)).to eq("4")
        expect(assigns(:payment_frequency)).to eq("ONE")

        [:name, :quantity, :currency, :price].each do |k|
          expect(assigns(:item)).to have_key(k)
        end

        [:currency, :items].each do |k|
          expect(assigns(:transaction)).to have_key(k)
        end
        
        expect(assigns(:transaction)[:payment_id]).not_to be_nil
        expect(assigns(:donation)).not_to be_nil
        expect(assigns(:donation)[:payment_id]).to eq(assigns(:transaction)[:payment_id])
        expect(subject).to redirect_to(assigns(:redirect_url))
      end

      it 'should assign values to create CUSTOM recurring payment' do
        get :checkout, params: { make_donation: { donation_amount: 4, payment_freq: "WEEK" } }
        expect(assigns(:user)).not_to be_nil
        expect(assigns(:money)).to eq("4")
        expect(assigns(:payment_frequency)).to eq("WEEK")
        expect(assigns(:transaction)["payment_definitions"][0]["amount"]["value"]).not_to be_nil
        expect(assigns(:transaction)["payment_definitions"][0]["frequency"]).not_to be_nil
        expect(assigns(:subscription_change)).not_to be_nil
        expect(assigns(:donation)).not_to be_nil
        expect(assigns(:donation)[:payment_id]).to eq(assigns(:subscription_change).token)
        expect(subject).to redirect_to(assigns(:redirect_url))
      end
    end
  end

  describe 'GET edit & POST recurring' do
    it 'should redirect if no user is signed in' do
      get :edit, params: { id: 0 }
      expect(response).to redirect_to(new_session_path)    
    end
    
    context 'given an existing user is signed in with `None` as the subscription' do
      before do
        @user = login_jacob
      end

      it 'should assign values to show USER what memberships are avaliable' do
        get :edit, params: {id: @user.id }
        expect(assigns(:subscription_plans)).to eq(PLAN_CONFIG.except("Custom"))
        expect(assigns(:handle_token)).to be_nil
        expect(assigns(:subscribed_to)).to eq(@user.membership_name)
      end

      it 'should redirect the user to edit if changes were NOT made' do
        post :recurring, params: { subscription: { subscribe: "None" } }
        expect(assigns(:user)).not_to be_nil
        expect(assigns(:membership)).to eq(@user.membership_name)
        expect(assigns(:recurring_id)).to be_nil
        expect(assigns(:redirect_url)).not_to be_nil
        expect(flash[:alert]).to eq("No changes made")
        expect(subject).to redirect_to(assigns(:redirect_url))
      end

      it 'should assign values to create A {BAD} MEMBERSHIP recurring payment when coming from `None`' do
        post :recurring, params: { subscription: { subscribe: "plan0" } }
        expect(assigns(:user)).not_to be_nil
        expect(assigns(:membership)).to eq(@user.membership_name)
        expect(assigns(:recurring_id)).to be_nil
        expect(assigns(:transaction)).not_to be_nil
        expect(assigns(:subscription_change)).not_to be_nil
        expect(assigns(:donation)).to be_nil
        expect(assigns(:redirect_url)).to be_nil
        expect(flash[:alert]).to eq(assigns(:subscription_change).error)
      end

      it 'should assign values to create MEMBERSHIP recurring payment when coming from `None` and redirect the user to PayPal' do
        post :recurring, params: { subscription: { subscribe: "plan1" } }
        expect(assigns(:user)).not_to be_nil
        expect(assigns(:membership)).to eq(@user.membership_name)
        expect(assigns(:recurring_id)).to be_nil
        expect(assigns(:transaction)).not_to be_nil
        expect(assigns(:subscription_change)).not_to be_nil
        expect(assigns(:donation)).not_to be_nil
        expect(assigns(:donation)[:payment_id]).to eq(assigns(:subscription_change).token)
        expect(subject).to redirect_to(assigns(:redirect_url))
      end

      it 'should flash MEMBERSHIP as `active` after heading OK from PayPal' do 
        agreement = PayPal::SDK::REST::Agreement.new(id: "0", token: "0", state: "Active")
        donation = MadeDonation.new(payer_id: "Plan 0")
        allow(@user).to receive(:update).with(membership: "0 ^ O")
        allow(agreement).to receive(:success?).and_return(true)
        allow(MadeDonation).to receive(:find_by).with(payment_id: "0").and_return(donation)
        allow(@controller).to receive(:execute_recurring_payment).and_return(agreement)

        get :edit, params: {id: @user.id, token: "0"}
        expect(assigns(:handle_token)).to eq("0")
        expect(assigns(:transaction)).to eq(donation)
        expect(flash[:alert]).to eq("Plan 0 Active")
      end

    end

  end

  

end
