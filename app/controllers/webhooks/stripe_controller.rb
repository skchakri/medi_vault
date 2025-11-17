# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      rescue JSON::ParserError => e
        Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
        return head :bad_request
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error "Stripe webhook signature verification failed: #{e.message}"
        return head :bad_request
      end

      # Handle the event
      case event['type']
      when 'checkout.session.completed'
        handle_checkout_session_completed(event['data']['object'])
      when 'customer.subscription.updated'
        handle_subscription_updated(event['data']['object'])
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event['data']['object'])
      when 'invoice.payment_succeeded'
        handle_invoice_payment_succeeded(event['data']['object'])
      when 'invoice.payment_failed'
        handle_invoice_payment_failed(event['data']['object'])
      else
        Rails.logger.info "Unhandled Stripe event type: #{event['type']}"
      end

      head :ok
    end

    private

    def handle_checkout_session_completed(session)
      user_id = session['client_reference_id'] || session['metadata']['user_id']
      user = User.find_by(id: user_id)

      return unless user

      plan = session['metadata']['plan']
      subscription_id = session['subscription']

      # Update user plan
      user.update!(
        plan: plan,
        plan_active: true,
        subscription_ends_at: 30.days.from_now, # Will be updated by subscription webhook
        stripe_customer_id: session['customer']
      )

      # Create payment record
      Payment.create!(
        user: user,
        stripe_payment_intent_id: session['payment_intent'],
        amount_cents: session['amount_total'],
        currency: session['currency'] || 'usd',
        status: :succeeded,
        description: "#{plan.capitalize} plan subscription",
        paid_at: Time.current
      )

      Rails.logger.info "Checkout completed for user #{user.id}, plan: #{plan}"
    end

    def handle_subscription_updated(subscription)
      user = User.find_by(stripe_customer_id: subscription['customer'])
      return unless user

      # Update subscription end date
      subscription_end = Time.at(subscription['current_period_end'])
      user.update!(
        subscription_ends_at: subscription_end,
        plan_active: subscription['status'] == 'active'
      )

      Rails.logger.info "Subscription updated for user #{user.id}"
    end

    def handle_subscription_deleted(subscription)
      user = User.find_by(stripe_customer_id: subscription['customer'])
      return unless user

      # Downgrade to free plan
      user.update!(
        plan: :free,
        plan_active: false,
        subscription_ends_at: nil
      )

      Rails.logger.info "Subscription canceled for user #{user.id}"
    end

    def handle_invoice_payment_succeeded(invoice)
      user = User.find_by(stripe_customer_id: invoice['customer'])
      return unless user

      # Create payment record for recurring payment
      Payment.create!(
        user: user,
        stripe_payment_intent_id: invoice['payment_intent'],
        amount_cents: invoice['amount_paid'],
        currency: invoice['currency'],
        status: :succeeded,
        description: "Subscription renewal",
        paid_at: Time.at(invoice['created'])
      )

      Rails.logger.info "Payment succeeded for user #{user.id}, amount: #{invoice['amount_paid']}"
    end

    def handle_invoice_payment_failed(invoice)
      user = User.find_by(stripe_customer_id: invoice['customer'])
      return unless user

      # Log failed payment
      Rails.logger.warn "Payment failed for user #{user.id}"

      # TODO: Send email notification to user about failed payment
    end
  end
end
