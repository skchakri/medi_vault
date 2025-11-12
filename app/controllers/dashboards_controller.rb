# frozen_string_literal: true

class DashboardsController < ApplicationController
  def show
    @credentials = current_user.credentials.by_expiration.limit(10)
    @expiring_soon_count = current_user.credentials.expiring_soon.count
    @expired_count = current_user.credentials.expired.count
    @total_credentials = current_user.credentials_count
    @upcoming_alerts = current_user.alerts.upcoming.limit(5)
    @recent_notifications = current_user.notifications.recent.limit(5)
  end
end
