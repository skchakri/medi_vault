# frozen_string_literal: true

class AlertDispatcherJob < ApplicationJob
  queue_as :alerts

  retry_on StandardError, wait: 1.hour, attempts: 3

  def perform(alert_id)
    alert = Alert.find(alert_id)

    return if alert.sent? || alert.cancelled?

    user = alert.user
    credential = alert.credential

    # Send email notification
    if user.notification_email
      notification = create_notification(alert, user, :email)
      AlertMailer.expiration_alert(alert, user, credential).deliver_later(queue: :mailers)
      notification.mark_as_sent!
    end

    # Send SMS notification (Pro plan only)
    if user.can_use_sms? && user.notification_sms
      notification = create_notification(alert, user, :sms)
      SmsNotificationJob.perform_later(notification.id)
    end

    # Mark alert as sent
    alert.update!(status: :sent, sent_at: Time.current)

    Rails.logger.info "Alert #{alert_id} dispatched successfully"
  rescue => e
    alert.update!(status: :failed)
    Rails.logger.error "Failed to dispatch alert #{alert_id}: #{e.message}"
    raise
  end

  private

  def create_notification(alert, user, channel)
    Notification.create!(
      user: user,
      credential: alert.credential,
      channel: channel,
      alert_offset_days: alert.offset_days,
      content: alert.formatted_message,
      status: :pending
    )
  end
end
