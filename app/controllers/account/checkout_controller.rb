# frozen_string_literal: true

module Account
  class CheckoutController < ApplicationController
    before_action :authenticate_user!

    def create
      plan = params[:plan] # "basic" or "pro"
      billing_period = params[:billing_period] || "monthly" # "monthly" or "yearly"

      price_id = get_price_id(plan, billing_period)

      if price_id.nil?
        redirect_to account_subscription_path, alert: "Invalid plan or billing period selected."
        return
      end

      session = Stripe::Checkout::Session.create({
        customer_email: current_user.email,
        client_reference_id: current_user.id.to_s,
        payment_method_types: ['card'],
        line_items: [{
          price: price_id,
          quantity: 1,
        }],
        mode: 'subscription',
        success_url: account_subscription_url + '?session_id={CHECKOUT_SESSION_ID}&success=true',
        cancel_url: account_subscription_url + '?canceled=true',
        metadata: {
          user_id: current_user.id,
          plan: plan,
          billing_period: billing_period
        },
        subscription_data: {
          metadata: {
            user_id: current_user.id,
            plan: plan
          }
        }
      })

      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      redirect_to account_subscription_path, alert: "Payment processing error. Please try again."
    end

    private

    def get_price_id(plan, billing_period)
      case [plan, billing_period]
      when ['basic', 'monthly']
        ENV['STRIPE_BASIC_MONTHLY_PRICE_ID']
      when ['basic', 'yearly']
        ENV['STRIPE_BASIC_YEARLY_PRICE_ID']
      when ['pro', 'monthly']
        ENV['STRIPE_PRO_MONTHLY_PRICE_ID']
      when ['pro', 'yearly']
        ENV['STRIPE_PRO_YEARLY_PRICE_ID']
      else
        nil
      end
    end
  end
end
