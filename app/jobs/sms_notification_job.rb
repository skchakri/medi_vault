# frozen_string_literal: true

class SmsNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(notification_id)
    notification = Notification.find(notification_id)
    user = notification.user

    unless user.can_use_sms?
      notification.mark_as_failed!("User does not have SMS enabled or phone not verified")
      return
    end

    # Get Twilio credentials from API settings
    twilio_sid = ApiSetting.get('twilio_sid')
    twilio_token = ApiSetting.get('twilio_token')
    twilio_from = ApiSetting.get('twilio_from')

    unless twilio_sid && twilio_token && twilio_from
      notification.mark_as_failed!("Twilio not configured")
      Rails.logger.error "Twilio not configured"
      return
    end

    # Send SMS using Twilio
    begin
      require 'twilio-ruby'
      client = Twilio::REST::Client.new(twilio_sid, twilio_token)

      message = client.messages.create(
        from: twilio_from,
        to: user.phone,
        body: notification.content
      )

      notification.mark_as_sent!
      Rails.logger.info "SMS sent to #{user.phone}: #{message.sid}"
    rescue Twilio::REST::RestError => e
      notification.mark_as_failed!("Twilio error: #{e.message}")
      Rails.logger.error "Failed to send SMS: #{e.message}"
      raise
    end
  end
end
