# app/services/paypal_service.rb
include ActionView::Helpers::NumberHelper
require 'addressable/uri'
require 'paypal-sdk-rest'
require 'time'

class PaypalService
  def initialize params
    @transaction = params[:transaction]
    @return_url = params[:return_url]
    @cancel_url = params[:cancel_url]
    @money = params[:money]
    @currency = @transaction[:currency]
  end
   
  def create_instant_payment
    # puts number_with_precision(@money, precision: 2), 'money honey'
    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: { payment_method: "paypal" },
      redirect_urls: { return_url: @return_url, cancel_url: @cancel_url },
      transactions: [{ item_list: { items: get_item_list },
        amount: { total: number_with_precision(@money, precision: 2),
        currency: @currency }
      }]
    })
    payment.create
    payment
  end

  def create_and_active_recurring_plan
    plan = PayPal::SDK::REST::Plan.new(plan_param)
    plan.update(active_plan_params) if plan.create
    plan # If any error occured, the message will be saved in plan.error
  end

  def self.execute_payment payment_id, payer_id
      payment = PayPal::SDK::REST::Payment.find(payment_id)
      puts "type: #{payment.class}"
      payment.execute(payer_id: payer_id) unless payment.error
      payment
  end

  def create_agreement(plan)
    agreement = PayPal::SDK::REST::Agreement.new(agreement_param(plan.id))
    agreement.create
    # If any error occured, the message will be saved in agreement.error
    agreement
  end

  def create_recurring_agreement
    plan = create_and_active_recurring_plan
    if plan && plan.success?
      agreement = create_agreement(plan)
    end
    (plan unless plan.success?) || agreement
  end

  def self.execute_agreement(agreement_token)
    # Use the token to execute this agreement
    agreement = PayPal::SDK::REST::Agreement.new(token: agreement_token)
    agreement.execute unless agreement.error
    agreement # the log will be saved in this object if there's error
  end
   
  def self.cancel_agreement(agreement_id)
    puts "***PP Service cancelling #{agreement_id}"
    # Use the id to execute this agreement
    agreement = PayPal::SDK::REST::Agreement.new(id: agreement_id)
    agreement.cancel(PayPal::SDK::REST::AgreementStateDescriptor.new(note: "Cancellation")) unless agreement.error
    agreement # the log will be saved in this object if there's error
  end

  ###################################################################################
  # below are the definitions of methods that recieve instant payment notifications #
  # https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNandPDTVariables/ #
  ###################################################################################
  def self.paypal_ipn(params)
    puts "&&IPN&&===", "#{params}"
    if recurring_transaction = valid_message_and_get_recurring_transaction(params)
      case categorize_paypal_ipn(recurring_transaction.price, params)
      when "instant_payment"
        # add a recurring payment, related to recurring_transaction
        # (no matter fail or success)
        puts "!!Instant Payment Notification was Received!!"
        user_of_recurring_txn = recurring_transaction.user_id
        # create a new transaction for the user after we know that the
        # payment has been completed
        MadeDonation.create({user_id: user_of_recurring_txn, 
          payment_id: params["txn_id"],
          parent_txn: recurring_transaction.payment_id,
          recurring: true,
          payer_id: params["payer_id"], 
          price: params["amount"]}) if params["payment_status"].eql?("Completed")
        # transaction = recurring_transaction.add_recurring_payment(params)
        # retry this amount if payment if failed
        # RetryRecurringTransactionJob.perform_in(24.hour.to_i, params["outstanding_balance"]) if transaction.failed?
      when "status_update"
        puts "!!Instant Payment Notification was UPDATED!!"
        # possible status: active, pending, suspended, expired, cancelled
        status = params["profile_status"]
        recurring_transaction.update(recurring: false) if status.eql?("Cancelled") || status.eql?("Expired") || status.eql?("Suspended")
      # when "refund_payment"
      #   # record this payment's status to refunded
      #   transaction = Transaction.find_by_payment_no(params["parent_txn_id"])
      #   transaction.update(status: "refund", full_log: params.to_s)
      end
      # success
    else
      puts "$$$$$$THERE WAS AN ERROR$$$$$"
      # error
    end
  end

  private
    # PayPal will also check all the currencies and subtotals
    # whether are match to the currency and total amount in payment object.
    # It's not a required field, but it's better to show all details
    # for your buyers when getting their approval.
  def get_item_list
    arr = []
    @transaction[:items].each do |item|
      arr << { name: item[:name], price: item[:price], currency: item[:currency], quantity: item[:quantity] }
    end
  end
  def active_plan_params
    {
      op: "replace",
      value: { state: "ACTIVE" },
      path: "/"
    }
  end

  ###################################################################################
  # below are the definitions of methods that recieve instant payment notifications #
  ###################################################################################

  def self.valid_message_and_get_recurring_transaction(params)
    # use SDK built-in method to validate this message is sent by PayPal
    # have to transfer this parameter's type from hash to HTTP parameters type..
    puts "Query was^^====", params.to_query
    paypal_message = PayPal::SDK::Core::API::IPN::Message.new(CGI.unescape(params.to_query))
    if paypal_message.valid? &&
      payment_id = params.fetch("recurring_payment_id", false)
      MadeDonation.find_by(payment_id: payment_id)
    end
  end

  # {"payment_cycle"=>"Monthly", "txn_type"=>"recurring_payment_profile_cancel", "last_name"=>"User", "next_payment_date"=>"N/A",
  # "residence_country"=>"US", "initial_payment_amount"=>"0.00", "currency_code"=>"USD",
  # "time_created"=>"18:43:45 Nov 18, 2019 PST", "verify_sign"=>"ASai6Zx.zbenDTXHaNV6Igqh3h3aAuBzmJvNMWdwZCz1vrYpZghjQh8y",
  # "period_type"=>" Regular", "payer_status"=>"verified", "test_ipn"=>"1", "tax"=>"0.00", "payer_email"=>"user@dms-user.com",
  # "first_name"=>"DMS", "receiver_email"=>"root@dms-user.com", "payer_id"=>"D7MH32PSBP23C", "product_type"=>"1", "shipping"=>"0.00",
  # "amount_per_cycle"=>"1.00", "profile_status"=>"Cancelled", "charset"=>"windows-1252", "notify_version"=>"3.9", "amount"=>"1.00",
  # "outstanding_balance"=>"0.00", "recurring_payment_id"=>"I-EE5J6KLNXG90", "product_name"=>"description of agreement plan1",
  # "ipn_track_id"=>"b0d58559a2730"}
  def self.categorize_paypal_ipn(transaction_currency, params)
    payment_type = params["payment_type"]
    txn_id = params["txn_id"] || params["initial_payment_txn_id"]
    txn_type = params["txn_type"]
    per_cycle_amt = params["amount_per_cycle"]
    if params["resend"].eql?("true") &&
         !MadeDonation.find_by(payment_id: txn_id).nil?
      return "resend"
    end
    # There's no txn_id if payment failed
    # `recurring_payment_profile_cancel` if profile was cancelled
    if (txn_type.eql?("recurring_payment_failed") || txn_id) && per_cycle_amt.eql?(transaction_currency)
      if params["payment_status"].eql?("Refunded") &&
           !MadeDonation.find_by(payment_id: params["parent_txn_id"]).nil?
        "refund_payment"
      else
        "instant_payment"
      end
    elsif !(payment_type && txn_id)
      "status_update"
    end
  end
 
  def plan_param
    # customize your own plan parameters with:  https://developer.paypal.com/docs/api/payments.billing-plans/#plan_create
    # {
    #   name: @product.title,
    #   description: @product.description,
    #   type: "FIXED",
    #   merchant_preferences: { ... },
    #   payment_definitions: { ... },
    #   ...
    #  }
    plan_only = deep_copy(@transaction)
    plan_only.delete("agreement")
    plan_only["merchant_preferences"]["cancel_url"] = @cancel_url
    plan_only["merchant_preferences"]["return_url"] = @return_url    
    puts "%%%%PLAN PARAMERTERS%%%","#{plan_only}" 
    plan_only
  end

  def agreement_param plan_id
    # customize you own agreement with: https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_create
    # {
    #   name: @product.title,
    #   description: @product.description,
    #   # you can set up different start date according to the product
    #   # or just set it to the time right after you create this agreement.
    #   # In ISO8601 Format:  YYYY-MM-DDTHH:MM:SSTimeZone
    #   start_date: get_agreement_start_date,
    #   payer: { payment_method: "paypal" },
    #   plan: { id: plan_id }
    # }
    puts "***TRANSACTION&&&&^^^^", "#{@transaction}"
    puts  "****BEFORE TIME OF AGREEMENT****", Time.now.iso8601
    only_agreement = deep_copy(@transaction)
    only_agreement = only_agreement["agreement"]
    only_agreement["start_date"] = (Time.now + 15.minutes).iso8601 if only_agreement["start_date"].blank?
    only_agreement["plan"]["id"] = plan_id
    puts "%%%%AGREEMENT PARAMERTERS%%%","#{only_agreement}"
    only_agreement
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end

end