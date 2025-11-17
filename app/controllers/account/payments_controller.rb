# frozen_string_literal: true

module Account
  class PaymentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @payments = current_user.payments
                              .recent
                              .page(params[:page])
                              .per(20)

      @stats = {
        total_paid: current_user.payments.successful.sum(:amount_cents) / 100.0,
        payment_count: current_user.payments.successful.count,
        this_year: current_user.payments.successful.this_year.sum(:amount_cents) / 100.0
      }
    end
  end
end
