class DonationTransactionsController < ApplicationController
  before_action :authenticate_user!, except: [:recurring]

  def index
    redirect_to new_donation_transaction_path
  end

  def new
    if params.has_key?(:token) && params.has_key?(:paymentId) && params.has_key?(:PayerID)
    # passed upon success
    # !-> PARAMS <-!
    # {"paymentId"=>"PAYID-LWTZFDQ5HY60034BT5063747", "token"=>"EC-7NE090679P7478832", "PayerID"=>"D7MH32PSBP23C", "controller"=>"donation_transaction", "action"=>"new"}
      success
    elsif params.has_key?(:token)
    # passed upon cancellation
    # !-> PARAMS <-!
    # {"token"=>"EC-7W133018A56947646", "controller"=>"donation_transaction", "action"=>"new"}
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
      @donation = MadeDonation.new({user_id: @user.id,
        payment_id: @payment.id,
        price: @money,
        token: @payment.token})
      # validate the user before saving
      @donation.save(context: :user)
      # puts @donation.attributes, 'donation'
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
      @transaction.destroy
      flash.now[:alert] = "Donation Cancelled"
    end
  end

  def edit
    puts "&&EDIT PARAMS&&==","#{params}"
    # to show the current plans
    @subscription_plans = PLAN_CONFIG
    @handle_token = params[:token]
    handle_recur_token if @handle_token
    @subscribed_to = current_user.membership and return
  end

  def recurring
    this_t = :authenticate_user! unless !params.has_key?(:user_id)
    puts "#{params}"
    @user = current_user
    subscribe_to = params[:subscription]
    if subscribe_to["subscribe"] == @user.membership
      # fix this 
      flash.now[:alert] = "No changes made"
      return
    end 
    if subscribe_to["subscribe"] == 'None'
      response = PaypalService.cancel_agreement(@user.recurring_id)
      @user.update(membership: "None") and @user.recurring_record.update(recurring: false) if response.success? # else render 'something_wrong'
    end
    @transaction = PLAN_CONFIG[subscribe_to["subscribe"]].clone
    if (@subscription_change = new_recurring_paypal_service).error.nil?
      # Because the agreement's id hasn't been generated yet.
      # (the id will be generated after we execute the agreement)
      # You should save the @subscription_change.token in your transaction
      puts "VALUE of AMONUT!^^", "#{@transaction["payment_definitions"][0]["amount"]["value"]}"
      puts "^^SUB ID^^", "#{@subscription_change.token}"
      @transaction.update(payment_no: @subscription_change.token)
      @donation = MadeDonation.new({user_id: @user.id, 
        payment_id: @subscription_change.token, 
        price: @transaction["payment_definitions"][0]["amount"]["value"],
        token: @subscription_change.token,
        payer_id: @transaction["name"],
        recurring: true})
      # validate the user before saving
      @donation.save(context: :user)
      # The url to redirect the buyer
      @redirect_url = @subscription_change.links.find{|v| v.method == "REDIRECT" }.href
      # save other @subscription_change data if you need
      redirect_to @redirect_url and return
      # on sucess Paypal will repspond ==> token=EC-6KK985826M006452E to success_url
      # on user cancellation Paypal will respond ==> token=EC-1BL82517H7178791W to cancel_url
      
    else
      puts "%%%%PAYMENT ERROR%%%%", @payment.error
    end
    # set up recurring donation!
    # if updating existing user, authenticate
    # otherwise, just do it
  end

   
  private
    def new_paypal_service
      PaypalService.new({
        transaction: @transaction,
        return_url: paypal_transaction_success_url('new'),
        cancel_url: paypal_transaction_cancel_url('new'),
        money: @money
      }).create_instant_payment
    end

    def new_recurring_paypal_service
      PaypalService.new({
        transaction: @transaction,
        return_url: paypal_transaction_success_url(current_user.id.to_s()+'/edit'),
        cancel_url: paypal_transaction_cancel_url(current_user.id.to_s()+'/edit')
      }).create_recurring_agreement
    end


    def paypal_transaction_cancel_url fn
      url = (Rails.env.test? || Rails.env.development?) ? ENV['APP_HOSTNAME_TEST'] : ENV['APP_HOSTNAME_PRODUCTION']
      url+= (fn) ? 'donation_transactions/'+fn : 'donation_transactions'
    end

    def paypal_transaction_success_url fn
      url = (Rails.env.test? || Rails.env.development?) ? ENV['APP_HOSTNAME_TEST'] : ENV['APP_HOSTNAME_PRODUCTION']
      url+= (fn) ? 'donation_transactions/'+fn : 'donation_transactions'
    end

    def build_item p
    {
      name: 'Brazos Valley Jazz Society Donation',
      quantity: 1,
      currency: "USD",
      price: p
    }
    end

    def handle_recur_token
      #find the started Record
      @user = current_user
      @transaction = MadeDonation.find_by(payment_id: @handle_token)
      # started transaction was not found
      if @transaction.nil?
        render 'something_wrong' and return
      else
        # execute the payment
        @payment = execute_recurring_payment(@handle_token)
        if @payment.success?
          # Remember to save the agreement's id for future use!
          puts "PAYMENT_PLAN^^^", "#{@payment.id}", "#{@payment.state}", "#{@payment.payer.payer_info.payer_id}"
          # initially the plan the user selected was set to `payer_id`
          update_membership = @transaction.payer_id
          @user.update(membership: update_membership)
          @transaction.update(payment_id: @payment.id)
          @transaction.update(payer_id: @payment.payer.payer_info.payer_id)
          flash.now[:alert] = @payment.state
          # @transaction.success!
          # save other data if need
        else
          # @transaction.fail!
          # Show error messages by using @payment.error to the user
          flash.now[:alert] = @payment.error
          # @payment.error["name"] = "INVALID TOKEN" when user cancels and returns to store
          puts "&&PLAN AGREEMENT STATUS&&==", @payment.state
          # ...
        end
      end
    end

    def find_plan_by_agreement_name name
      PLAN_CONFIG.each do |plan_key, plan_val|
        return plan_val["name"] if plan_val["agreement"]["name"] == name
      end
      'None'
    end

    def build_transaction it
    {
      currency: "USD",
      items: it
    }
    end

    def execute_paypal_payment params
      PaypalService.execute_payment(params[:payment_id], params[:payer_id])
    end

    def execute_recurring_payment agreement_token
      PaypalService.execute_agreement(agreement_token)
    end
    
end
