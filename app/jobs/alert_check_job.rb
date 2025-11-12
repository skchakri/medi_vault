# frozen_string_literal: true

class AlertCheckJob < ApplicationJob
  queue_as :alerts

  def perform
    # Find all alerts that are due today and still pending
    alerts_due = Alert.due_today

    Rails.logger.info "Found #{alerts_due.count} alerts due today"

    alerts_due.find_each do |alert|
      AlertDispatcherJob.perform_later(alert.id)
    end
  end
end
