# frozen_string_literal: true

module Account
  class SubscriptionsController < ApplicationController
    def show
      @user = current_user
      @plan_limits = plan_limits

      # Handle Stripe checkout callbacks
      if params[:success] == 'true'
        flash.now[:notice] = "Payment successful! Your subscription has been activated."
      elsif params[:canceled] == 'true'
        flash.now[:alert] = "Payment was canceled. Your subscription was not updated."
      end
    end

    def update
      @user = current_user
      new_plan = params[:plan]

      unless %w[free basic pro].include?(new_plan)
        flash[:alert] = "Invalid plan selected"
        redirect_to account_subscription_path and return
      end

      # In a real app, this would integrate with Stripe
      # For now, we'll just update the plan directly
      @user.update!(
        plan: new_plan,
        plan_active: true,
        subscription_ends_at: 1.month.from_now
      )

      flash[:notice] = "Successfully upgraded to #{new_plan.titleize} plan!"
      redirect_to account_subscription_path
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Failed to update subscription: #{e.message}"
      redirect_to account_subscription_path
    end
  end
end
