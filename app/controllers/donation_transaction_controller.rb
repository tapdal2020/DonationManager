class DonationTransactionController < ApplicationController
  def new
    # passed upon cancellation
    # !-> PARAMS <-!
    # {"token"=>"EC-7W133018A56947646", "controller"=>"donation_transaction", "action"=>"new"}
    # !-> PARAMS <-!
    # passed upon success
    # !-> PARAMS <-!
    # {"paymentId"=>"PAYID-LWTZFDQ5HY60034BT5063747", "token"=>"EC-7NE090679P7478832", "PayerID"=>"D7MH32PSBP23C", "controller"=>"donation_transaction", "action"=>"new"}
    # !-> PARAMS <-!
    puts "!-> PARAMS <-!", params, "!-> PARAMS <-!"
  end

  def checkout
    #...
    # get the amount from the forms
    @item = build_item(params[:donation][:donation_amount])
    @transaction = build_transaction([@item])
    @money = params[:donation][:donation_amount]
    puts 'donation is', @money
    # redirect_to 'https://google.com'
    # return
    ## checking
    # check whether there was an error happened when created the payment
    if (@payment = new_paypal_service).error.nil?
      # record the payment id provided by PayPal for future use
      @transaction.update(payment_no: @payment.id)
      puts @payment.id, "PAYMENT ID"
      # The url to redirect the buyer
      @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
      redirect_to @redirect_url
      # save other @payment data if you need
    else
      # if the payment is not created successfully,
      # the error message will be saved in @payment.error
      @message = @payment.error
      # Show the error message to user
    end
    puts "!TRANSACTION DETAILS!", @transaction, "!TRANSACTION DETAILS!"
  #...
  end

  def success
    puts "!!!SUCCESS!!!", params, "!!!SUCCESS!!!"
    payment_id = params.fetch(:paymentId, nil)
    if payment_id.present?
      @transaction = Transaction.find(payment_id)
      @payment = execute_paypal_payment({
        token: payment_id, payment_id: payment_id,
        payer_id: params[:PayerID]})
    end
    # ...
    if @transaction && @payment && @payment.success?
      # set transaction status to success and save some data
    else
      # show error message
    end
  #    ...
  end
  
  def cancelled
    puts "??!USER CANCELLED!??", params, "??!USER CANCELLED!??"
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
      'http://localhost:3000/donation_transaction/new'
    end

    def paypal_transaction_success_url
      'http://localhost:3000/donation_transaction/new'
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
