# frozen_string_literal: true

module Admin
  class ReportsController < AdminController
    def index
      @total_users = User.count
      @total_credentials = Credential.count
      @total_alerts = Alert.count
      @expired_credentials_count = Credential.expired.count
      @expiring_soon_count = Credential.expiring_soon.count
    end

    def users
      @users = User.all.includes(:credentials).order(:created_at)
      @total_users = @users.count
      @users_by_plan = @users.group_by(&:plan)
    end

    def credentials
      @credentials = Credential.includes(:user).order(:end_date)
      @credentials_by_status = @credentials.group_by(&:status)
      @total_credentials = @credentials.count
      @expiring_soon = @credentials.expiring_soon
      @expired = @credentials.expired
    end

    def llm_usage
      @llm_requests = LlmRequest.all.includes(:user)

      # Combined statistics
      @total_requests = @llm_requests.count
      @total_tokens = @llm_requests.sum(:total_tokens)
      @total_cost_cents = @llm_requests.sum(:cost_cents)
      @total_cost = @total_cost_cents / 100.0

      # Usage by user
      @usage_by_user = @llm_requests.group_by(&:user_id).map do |user_id, requests|
        user = User.find(user_id)
        {
          user: user,
          request_count: requests.count,
          total_tokens: requests.sum(:total_tokens),
          total_cost_cents: requests.sum(:cost_cents),
          successful: requests.count { |r| r.success },
          failed: requests.count { |r| !r.success }
        }
      end.sort_by { |stat| -stat[:total_cost_cents] }

      # Usage by model
      @usage_by_model = @llm_requests.group_by(&:model).map do |model, requests|
        {
          model: model,
          request_count: requests.count,
          total_tokens: requests.sum(:total_tokens),
          total_cost_cents: requests.sum(:cost_cents),
          providers: requests.map(&:provider).uniq.join(', ')
        }
      end.sort_by { |stat| -stat[:total_cost_cents] }

      # Cost breakdown by user
      @cost_by_user = @usage_by_user.map do |stat|
        {
          user_email: stat[:user].email,
          cost_cents: stat[:total_cost_cents],
          percentage: (@total_cost_cents > 0 ? (stat[:total_cost_cents] / @total_cost_cents.to_f * 100).round(2) : 0)
        }
      end

      # Cost breakdown by model
      @cost_by_model = @usage_by_model.map do |stat|
        {
          model: stat[:model],
          cost_cents: stat[:total_cost_cents],
          percentage: (@total_cost_cents > 0 ? (stat[:total_cost_cents] / @total_cost_cents.to_f * 100).round(2) : 0)
        }
      end
    end
  end
end
