# app/services/paypal_service.rb
include ActionView::Helpers::NumberHelper
require 'paypal-sdk-rest'

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
 
  def plan_param
    # customize your own plan parameters with:  https://developer.paypal.com/docs/api/payments.billing-plans/#plan_create
    {
      name: @product.title,
      description: @product.description,
      type: "FIXED",
      merchant_preferences: { ... },
      payment_definitions: { ... },
      ...
     }
  end

  def agreement_param plan_id
    # customize you own agreement with: https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_create
    {
      name: @product.title,
      description: @product.description,
      # you can set up different start date according to the product
      # or just set it to the time right after you create this agreement.
      # In ISO8601 Format:  YYYY-MM-DDTHH:MM:SSTimeZone
      start_date: get_agreement_start_date,
      payer: { payment_method: "paypal" },
      plan: { id: plan_id }
    }
  end
end