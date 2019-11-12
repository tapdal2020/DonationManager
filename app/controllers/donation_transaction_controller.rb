class DonationTransactionController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to new_donation_transaction_path
  end

  def new
    if params.has_key?(:token) && params.has_key?(:paymentId) && params.has_key?(:PayerID)
    # passed upon success
    # !-> PARAMS <-!
    # {"paymentId"=>"PAYID-LWTZFDQ5HY60034BT5063747", "token"=>"EC-7NE090679P7478832", "PayerID"=>"D7MH32PSBP23C", "controller"=>"donation_transaction", "action"=>"new"}
    # !-> PARAMS <-!
      success
    elsif params.has_key?(:token)
    # passed upon cancellation
    # !-> PARAMS <-!
    # {"token"=>"EC-7W133018A56947646", "controller"=>"donation_transaction", "action"=>"new"}
    # !-> PARAMS <-!
      cancelled
    else
      @donation = MadeDonation.new
    end
    # puts "!-> PARAMS <-!", params, session[:user_id], "!-> PARAMS <-!"
  end

  def checkout
    # get the user buy id
    @user = current_user
    @money = params[:donation][:donation_amount]
    # get the amount from the forms
    @item = build_item(@money)
    @transaction = build_transaction([@item])
    # check whether there was an error happened when created the payment
    if (@payment = new_paypal_service).error.nil?
      # record the payment id provided by PayPal for future use
      @transaction.update(payment_id: @payment.id)
      @donation = MadeDonation.new({user_id: @user.id, payment_id: @payment.id, price: @money, token: @payment.token})
      # validate the user before saving
      @donation.save(context: :user)
      # puts @donation.attributes, 'donation'
      # redirect_to 'https://google.com'
      # return
      # The url to redirect the buyer
      @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
      redirect_to @redirect_url and return
      # save other @payment data if you need
    else
      # if the payment is not created successfully,
      # the error message will be saved in @payment.error
      @message = @payment.error
      # Show the error message to user
    end
   # puts "!TRANSACTION DETAILS!", @transaction, "!TRANSACTION DETAILS!"
  #...
  end

  def success
    # puts "!!!SUCCESS!!!", params, "!!!SUCCESS!!!"
    payment_id = params.fetch(:paymentId, nil)
    @PayerID = params[:PayerID]
    if payment_id.present?
      @transaction = MadeDonation.find_by(payment_id: payment_id)
      if @transaction.nil?
        render 'something_wrong' and return
      else
        @payment = execute_paypal_payment({
          token: payment_id, payment_id: payment_id,
          payer_id: @PayerID})
      end
    end
    # ...
    if @transaction && @payment && @payment.success?
      # set transaction status to success and save some data
      @transaction.update(payer_id: @PayerID)
      flash.now[:alert] = "Donation Succeeded"
    else
      # show error message
      flash.now[:alert] = @payment.error
    end
  #    ...
  end
  
  def cancelled
    # puts "??!USER CANCELLED!??", params, "??!USER CANCELLED!??"
    @transaction = MadeDonation.find_by(token: params[:token])
    if @transaction.nil?
      render 'something_wrong' and return
    else
      @transaction.destroy!
      flash.now[:alert] = "Donation Cancelled"
    end
  end
    
  private
    def new_paypal_service
      PaypalService.new({
        transaction: @transaction,
        return_url: paypal_transaction_success_url,
        cancel_url: paypal_transaction_cancel_url,
        money: @money
      }).create_instant_payment
    end

    def paypal_transaction_cancel_url
      url = (Rails.env.test? || Rails.env.development?) ? ENV['APP_HOSTNAME_TEST'] : ENV['APP_HOSTNAME_PRODUCTION']
      url+= 'donation_transaction/new'
    end

    def paypal_transaction_success_url
      url = (Rails.env.test? || Rails.env.development?) ? ENV['APP_HOSTNAME_TEST'] : ENV['APP_HOSTNAME_PRODUCTION']
      url+= 'donation_transaction/new'
    end

    def build_item p
    {
      name: 'Brazos Valley Jazz Society Donation',
      quantity: 1,
      currency: "USD",
      price: p
    }
    end

    def build_transaction it
    {
      currency: "USD",
      items: it
    }
    end

    def execute_paypal_payment(params)
      PaypalService.execute_payment(params[:payment_id], params[:payer_id])
    end
end
