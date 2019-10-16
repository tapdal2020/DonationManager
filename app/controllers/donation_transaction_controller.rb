class DonationTransactionController < ApplicationController
  def new
    
  end

  def checkout
      #...
      # check whether there was an error happened when created the payment
      if (@payment = new_paypal_service).error.nil?
        # record the payment id provided by PayPal for future use
        @transaction.update(payment_no: @payment.id)
        # The url to redirect the buyer
        @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
        # save other @payment data if you need
      else
        # if the payment is not created successfully,
        # the error message will be saved in @payment.error
        @message = @payment.error
        # Show the error message to user
      end
    #...
    end
  def success
      payment_id = params.fetch(:paymentId, nil)
      if payment_id.present?
        @transaction = Transaction.find(payment_id)
        @payment = execute_paypal_payment({
          token: payment_id, payment_id: payment_id,
          payer_id: params[:PayerID]})
      end
      ...
      if @transaction && @payment && @payment.success?
        # set transaction status to success and save some data
      else
        # show error message
      end
  #    ...
  end
    
  private
    def new_paypal_service
      PaypalService.new({
        transaction: @transaction,
        return_url: paypal_transaction_success_url,
        cancel_url: Paypal_transaction_cancel_url
      }).create_instant_payment
    end
    def execute_paypal_payment(params)
      PaypalService.execute_payment(params[:payment_id], params[:payer_id])
    end
end
