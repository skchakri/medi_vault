# frozen_string_literal: true

module Admin
  class DashboardController < AdminController
    def index
      @stats = {
        total_users: User.count,
        total_credentials: Credential.count,
        active_users: User.active_users.count,
        credentials_expiring_soon: Credential.expiring_soon.count,
        credentials_expired: Credential.expired.count,
        pending_alerts: Alert.pending.count,
        llm_requests_today: LlmRequest.where('created_at >= ?', Date.today).count,
        llm_total_cost: LlmRequest.total_cost
      }

      @recent_users = User.order(created_at: :desc).limit(10)
      @recent_credentials = Credential.includes(:user).order(created_at: :desc).limit(10)
      @recent_llm_requests = LlmRequest.includes(:user).order(created_at: :desc).limit(10)
    end
  end
end
