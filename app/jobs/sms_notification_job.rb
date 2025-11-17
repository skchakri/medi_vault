# frozen_string_literal: true

class SmsNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(notification_id)
    notification = Notification.find(notification_id)
    user = notification.user

    # Create usage tracking record
    usage = MessageUsage.create!(
      user: user,
      message_type: :sms,
      status: :pending,
      provider: 'twilio'
    )

    unless user.can_use_sms?
      error_msg = "User does not have SMS enabled or phone not verified"
      notification.mark_as_failed!(error_msg)
      usage.mark_as_failed!(error_msg)
      return
    end

    # Get Twilio credentials from API settings
    twilio_sid = ApiSetting.get('twilio_sid')
    twilio_token = ApiSetting.get('twilio_token')
    twilio_from = ApiSetting.get('twilio_from')

    unless twilio_sid && twilio_token && twilio_from
      error_msg = "Twilio not configured"
      notification.mark_as_failed!(error_msg)
      usage.mark_as_failed!(error_msg)
      Rails.logger.error error_msg
      return
    end

    # Send SMS using Twilio
    begin
      require 'twilio-ruby'
      client = Twilio::REST::Client.new(twilio_sid, twilio_token)

      # Replace long URLs with shortened versions
      content = shorten_urls_in_content(notification.content)

      message = client.messages.create(
        from: twilio_from,
        to: user.phone,
        body: content
      )

      # Calculate cost (Twilio pricing: ~$0.0075 per SMS in US)
      # Adjust based on your actual Twilio pricing
      segment_count = (content.length / 160.0).ceil
      cost_cents = (segment_count * 0.75).round # $0.0075 per segment = 0.75 cents

      notification.mark_as_sent!
      usage.update!(
        status: :sent,
        sent_at: Time.current,
        cost_cents: cost_cents
      )

      Rails.logger.info "SMS sent to #{user.phone}: #{message.sid} (#{segment_count} segments, $#{cost_cents / 100.0})"
    rescue Twilio::REST::RestError => e
      error_msg = "Twilio error: #{e.message}"
      notification.mark_as_failed!(error_msg)
      usage.mark_as_failed!(error_msg)
      Rails.logger.error "Failed to send SMS: #{e.message}"
      raise
    end
  end

  private

  def shorten_urls_in_content(content)
    # Find all URLs in the content and replace with shortened versions
    url_regex = %r{https?://[^\s]+}

    content.gsub(url_regex) do |url|
      short_url = UrlShortener.shorten(url)
      # Return full URL for SMS (needs protocol and host)
      # In production, this would use the actual domain
      "https://medivault.com#{short_url.short_path}"
    end
  end
end
