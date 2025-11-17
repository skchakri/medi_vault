# frozen_string_literal: true

class EmailNotificationJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(notification_id)
    notification = Notification.find(notification_id)
    user = notification.user
    credential = notification.credential

    # Create usage tracking record
    usage = MessageUsage.create!(
      user: user,
      message_type: :email,
      status: :pending,
      provider: 'smtp'
    )

    begin
      # Send email based on notification type
      if notification.alert_offset_days.present?
        # This is an alert notification
        alert = Alert.find_by(
          credential: credential,
          offset_days: notification.alert_offset_days
        )

        if alert
          AlertMailer.expiration_alert(alert, user, credential).deliver_now
        else
          raise "Alert not found for notification #{notification_id}"
        end
      else
        # Generic notification email
        # You can add other email types here as needed
        raise "Unknown notification type for #{notification_id}"
      end

      # Mark as sent
      notification.mark_as_sent!
      usage.update!(
        status: :sent,
        sent_at: Time.current,
        cost_cents: 0 # Email is essentially free
      )

      Rails.logger.info "Email sent to #{user.email} for notification #{notification_id}"
    rescue StandardError => e
      error_msg = "Email error: #{e.message}"
      notification.mark_as_failed!(error_msg)
      usage.mark_as_failed!(error_msg)
      Rails.logger.error "Failed to send email for notification #{notification_id}: #{e.message}"
      raise
    end
  end
end
