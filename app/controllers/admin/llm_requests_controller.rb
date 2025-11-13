# frozen_string_literal: true

module Admin
  class LlmRequestsController < AdminController
    def index
      @llm_requests = LlmRequest.includes(:user, :credential)
        .order(created_at: :desc)
        .page(params[:page])
        .per(50)

      @total_requests = LlmRequest.count
      @total_cost = LlmRequest.sum(:cost).to_f.round(2)
      @total_tokens = LlmRequest.sum(:total_tokens)
      @avg_cost = @total_requests > 0 ? (@total_cost / @total_requests).round(4) : 0
    end

    def show
      @llm_request = LlmRequest.find(params[:id])
    end
  end
end
