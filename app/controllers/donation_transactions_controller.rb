class DonationTransactionsController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :index]
  protect_from_forgery :except => [:index] #Otherwise the request from PayPal wouldn't make it to the controller
  def index
    # puts "&&&INDEX PARAMS&&====","#{permitted_paypal_params}"
    # example of message coming from paypal
    # {"payment_cycle"=>"Monthly", "txn_type"=>"recurring_payment_profile_cancel", "last_name"=>"User", "next_payment_date"=>"N/A",
    # "residence_country"=>"US", "initial_payment_amount"=>"0.00", "currency_code"=>"USD",
    # "time_created"=>"18:43:45 Nov 18, 2019 PST", "verify_sign"=>"ASai6Zx.zbenDTXHaNV6Igqh3h3aAuBzmJvNMWdwZCz1vrYpZghjQh8y",
    # "period_type"=>" Regular", "payer_status"=>"verified", "test_ipn"=>"1", "tax"=>"0.00", "payer_email"=>"user@dms-user.com",
    # "first_name"=>"DMS", "receiver_email"=>"root@dms-user.com", "payer_id"=>"D7MH32PSBP23C", "product_type"=>"1", "shipping"=>"0.00",
    # "amount_per_cycle"=>"1.00", "profile_status"=>"Cancelled", "charset"=>"windows-1252", "notify_version"=>"3.9", "amount"=>"1.00",
    # "outstanding_balance"=>"0.00", "recurring_payment_id"=>"I-EE5J6KLNXG90", "product_name"=>"description of agreement plan1",
    # "ipn_track_id"=>"b0d58559a2730"}
    # http query of this is
    # "amount=1.00&amount_per_cycle=1.00&charset=windows-1252&currency_code=USD&first_name=DMS&initial_payment_amount=0.00&ipn_track_id=b0d58559a2730&last_name=User&next_payment_date=N%2FA&notify_version=3.9&outstanding_balance=0.00&payer_email=user%40dms-user.com&payer_id=D7MH32PSBP23C&payer_status=verified&payment_cycle=Monthly&period_type=%20Regular&product_name=description%20of%20agreement%20plan1&product_type=1&profile_status=Cancelled&receiver_email=root%40dms-user.com&recurring_payment_id=I-EE5J6KLNXG90&residence_country=US&shipping=0.00&tax=0.00&test_ipn=1&time_created=18%3A43%3A45%20Nov%2018%2C%202019%20PST&txn_type=recurring_payment_profile_cancel&verify_sign=ASai6Zx.zbenDTXHaNV6Igqh3h3aAuBzmJvNMWdwZCz1vrYpZghjQh8y"
    PaypalService.paypal_ipn(permitted_paypal_params) and head :ok if permitted_paypal_params["verify_sign"]
    # render 'something_wrong'
    redirect_to new_donation_transaction_path
  end

  def new
    if params.has_key?(:token) && params.has_key?(:paymentId) && params.has_key?(:PayerID)
    # passed upon success
    # {"paymentId"=>"PAYID-LWTZFDQ5HY60034BT5063747", "token"=>"EC-7NE090679P7478832",
    # "PayerID"=>"D7MH32PSBP23C", "controller"=>"donation_transaction", "action"=>"new"}
      success
    elsif params.has_key?(:token)
    # passed upon cancellation
    # {"token"=>"EC-7W133018A56947646",
    # "controller"=>"donation_transaction", "action"=>"new"}
      cancelled
    else
      @donation = MadeDonation.new
    end
    # puts "!-> PARAMS <-!", params, session[:user_id], "!-> PARAMS <-!"
  end

  def checkout
    # get the user buy id
    @user = current_user
    @money = params[:make_donation][:donation_amount]
    @payment_frequency = params[:make_donation][:payment_freq]
    if not @payment_frequency.eql?("ONE") 
      handle_custom_recurrence
    else
      handle_normal_donation
    end
    do_redirect and return
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
    # puts "&&EDIT PARAMS&&==","#{params}"
    # to show the current plans

    if current_user.nil? && params[:from] != 'create'
      redirect_to new_session_path and return
    elsif params[:from] == 'create'
      recurring and return
    end

    @subscription_plans = PLAN_CONFIG.except("Custom")
    @handle_token = params[:token]
    puts "&&==Handling token #{@handle_token}"
    handle_recur_token if @handle_token
    @subscribed_to = current_user.membership_name and return
  end

  def recurring
    # @redirect_url = nil
    this_t = :authenticate_user! unless !params.has_key?(:user_id)
    puts "#{params}"
    @user = current_user
    if not params["cancel_id"].nil?
      @recurring_id = params["cancel_id"]
      if handle_user_agreement_cancellation
        @redirect_url=user_path(@user.id)
        do_redirect and return
      end
      return
    end
    @membership = @user.membership_name
    not_subscribed = @membership.eql?("None")
    # membership - billing agreement id stored for membership
    @recurring_id = @user.membership_id
    subscribe_to = params[:subscription]
    no_changes = subscribe_to["subscribe"].eql?(@membership)
    doing_unsubscribe = subscribe_to["subscribe"].eql?("None")
    handle_no_subscription_change and do_redirect and return if no_changes
    # else the user is changing the membership, so cancel and update profile
    handle_user_agreement_cancellation unless not_subscribed
    @user.update(membership: "None")
    @redirect_url = edit_donation_transaction_path(current_user.id) 
    @transaction = deep_copy(PLAN_CONFIG[subscribe_to["subscribe"]]) and
    validate_descriptions and set_membership_timestamp and 
    run_recurring_setup unless doing_unsubscribe or no_changes
    do_redirect and return
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

    def do_redirect
      redirect_to @redirect_url if not @redirect_url.nil?
    end
    
    def set_membership_timestamp
      @transaction["agreement"]["start_date"] = (Time.parse(ENV['APP_MEMBERSHIP_RECURRING_AT']) + 1.year).iso8601
    end

    def handle_normal_donation
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
        @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href and return
        # save other @payment data if you need
      else
        # if the payment is not created successfully,
        # the error message will be saved in @payment.error
        @redirect_url = nil
        flash[:alert] = @payment.error and return
        # Show the error message to user
      end
    end

    def handle_recur_token
      #find the started Record
      @user = current_user
      @transaction = MadeDonation.find_by(payment_id: @handle_token)
      # started transaction was not found
      if @transaction.nil?
        render 'something_wrong' and return
      else
        plan_was_custom = @transaction.payer_id.eql?(PLAN_CONFIG["Custom"]["name"])
        # execute the payment
        @payment = execute_recurring_payment(@handle_token)
        if @payment.success?
          # Remember to save the agreement's id for future use!
          puts "PAYMENT_PLAN^^^", "#{@payment.id}", "#{@payment.state}", "#{@payment.payer.payer_info.payer_id}"
          # initially the plan the user selected was set to `payer_id`
          custom_plan_name = PLAN_CONFIG["Custom"]["name"]
          update_membership = @transaction.payer_id
          # handles figuring out what payment id a membership tier is tied to
          mem_db = update_membership + " ^ " + @payment.id
          # we will not update the membership field of the user, given
          # the user has ran a custom recurring payment
          @user.update(membership: mem_db) unless update_membership.eql?(custom_plan_name)
          puts "Membership: #{@user.membership}"
          @transaction.update(payment_id: @payment.id)
          puts "UPDATED TRANSACTION TO HAVE PAYMENT ID #{@transaction.payment_id}"
          @transaction.update(payer_id: @payment.payer.payer_info.payer_id)
          flash.keep[:alert] = update_membership + " " + @payment.state
          # @transaction.success!
          # save other data if need
        else
          # @transaction.fail!
          # Show error messages by using @payment.error to the user
          e = @payment.error
          change_type = (plan_was_custom) ? "Reccuring Payment Setup" : "Subscription Change"
          @transaction.destroy and flash.keep[:alert] = change_type+" Cancelled" if @payment.error.name == "INVALID_TOKEN"
          # flash.now[:alert] = @payment.error
          # @payment.error["name"] = "INVALID_TOKEN" when user cancels and returns to store
          puts "&&PLAN AGREEMENT STATUS&&==", @payment.state
          # ...
        end
        redirect_to new_donation_transaction_path(id: @user.id) if plan_was_custom
      end
    end

    def run_recurring_setup
      price_val = @transaction["payment_definitions"][0]["amount"]["value"] if @transaction["name"].eql?(PLAN_CONFIG["Custom"]["name"]) else nil
      if (@subscription_change = new_recurring_paypal_service).error.nil?
        # Because the agreement's id hasn't been generated yet.
        # (the id will be generated after we execute the agreement)
        # You should save the @subscription_change.token in your transaction
        # puts "VALUE of AMONUT!^^", "#{@transaction["payment_definitions"][0]["amount"]["value"]}"
        # puts "^^SUB ID^^", "#{@subscription_change.token}"
        @transaction.update(payment_id: @subscription_change.token)
        puts "%% MAKING A RECURRING MEMBERSHIP CHANGE %%%%"
        @donation = MadeDonation.new({user_id: @user.id, 
          payment_id: @subscription_change.token, 
          price: price_val,
          frequency: @transaction["payment_definitions"][0]["frequency"],
          token: @subscription_change.token,
          payer_id: @transaction["name"],
          recurring: true})
        # validate the user before saving
        @donation.save(context: :user)
        # The url to redirect the buyer
        @redirect_url = @subscription_change.links.find{|v| v.method == "REDIRECT" }.href and return
        # save other @subscription_change data if you need
        # redirect_to @redirect_url and return
        # on sucess Paypal will repspond ==> token=EC-6KK985826M006452E to success_url
        # on user cancellation Paypal will respond ==> token=EC-1BL82517H7178791W to cancel_url
        
      else
        @redirect_url = nil
        flash[:alert] = @subscription_change.error and return
      end
      # set up recurring donation!
      # if updating existing user, authenticate
      # otherwise, just do it
    end

    def handle_custom_recurrence
      # Clone the custom outline
      @transaction = deep_copy(PLAN_CONFIG["Custom"])
      # set the values of frequency and amount specified from checkout
      @transaction["payment_definitions"][0]["amount"]["value"] = @money
      @transaction["payment_definitions"][0]["frequency"] = @payment_frequency
      puts "&&CUSTOM RECURRING PAYMENT &&===", "#{@transaction}"
      run_recurring_setup and return
    end


    def handle_user_agreement_cancellation
      puts "@@ handling #{@recurring_id}"
      response = PaypalService.cancel_agreement(@recurring_id)
      if response.success?
        @user.update(membership: "None") if @user.membership_id.eql?(@recurring_id)
        @user.recurring_record(@recurring_id).update(recurring: false)
        flash[:alert] = "Agreement Cancelled"
        return true
      else 
        puts "#{response.error}"
        render 'something_wrong'
        return false
      end
    end

    def handle_no_subscription_change
      # redirect_to
      @redirect_url = edit_donation_transaction_path(current_user.id)
      #do_redirect
      # fix this 
      flash[:alert] = "No changes made"
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

    def permitted_paypal_params
      params.permit(
      :payment_type, :payment_date, :payment_status,
      :payment_cycle, 
      :txn_type, :txn_id, :parent_txn_id,
      :last_name, 
      :next_payment_date, 
      :residence_country, 
      :initial_payment_amount, 
      :currency_code, 
      :time_created, 
      :verify_sign, 
      :period_type, 
      :payer_status, 
      :test_ipn, 
      :tax, 
      :payer_email, 
      :first_name, 
      :receiver_email, 
      :payer_id, 
      :product_type, 
      :shipping, 
      :amount_per_cycle, 
      :profile_status, 
      :charset, 
      :notify_version, 
      :amount, 
      :outstanding_balance, 
      :recurring_payment_id, 
      :product_name, 
      :ipn_track_id)
    end

    def validate_descriptions
        puts "^^in validate descriptions^^"
        plan_description = @transaction["description"]
        plan_description = plan_description.join(", ") if plan_description.respond_to?('join')
        puts "#{plan_description}"
        plan_description = plan_description[0..123]+'...' if plan_description.length > 127
        puts "#{plan_description}"
        @transaction["description"] = plan_description
    end
    
end
