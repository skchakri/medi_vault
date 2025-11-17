# frozen_string_literal: true

class SubscriptionRenewalJob < ApplicationJob
  queue_as :default

  def perform
    # Find users whose subscription ends in the next 3 days
    users_expiring_soon = User.where(
      'subscription_ends_at <= ? AND subscription_ends_at > ? AND plan_active = ?',
      3.days.from_now,
      Time.current,
      true
    )

    users_expiring_soon.find_each do |user|
      send_renewal_reminder(user)
    end

    # Find users whose subscription has expired
    expired_users = User.where(
      'subscription_ends_at <= ? AND plan_active = ?',
      Time.current,
      true
    )

    expired_users.find_each do |user|
      downgrade_to_free_plan(user)
    end

    Rails.logger.info "SubscriptionRenewalJob completed: #{users_expiring_soon.count} reminders sent, #{expired_users.count} users downgraded"
  end

  private

  def send_renewal_reminder(user)
    # Find or create subscription renewal email template
    template = EmailTemplate.find_by_type(:subscription_renewal)

    return unless template&.active

    days_until_expiry = ((user.subscription_ends_at - Time.current) / 1.day).ceil

    variables = {
      user_name: user.full_name,
      email: user.email,
      plan_name: user.plan.humanize,
      expiry_date: user.subscription_ends_at.strftime('%B %d, %Y'),
      days_remaining: days_until_expiry,
      renewal_link: "https://medivault.com/account/subscription"
    }

    # Send email based on user preference
    if user.both? || user.email_only?
      send_renewal_email(user, template, variables)
    end

    # Send SMS based on user preference (Pro plan only)
    if user.can_use_sms? && (user.both? || user.sms_only?) && template.has_sms_template?
      send_renewal_sms(user, template, variables)
    end

    Rails.logger.info "Sent renewal reminder to user #{user.id} (#{days_until_expiry} days remaining)"
  end

  def send_renewal_email(user, template, variables)
    # In a production app, you'd create a dedicated mailer for this
    # For now, we'll log it
    Rails.logger.info "Would send renewal email to #{user.email}"

    # Track the message
    MessageUsage.create!(
      user: user,
      message_type: :email,
      status: :sent,
      sent_at: Time.current,
      cost_cents: 0,
      provider: 'smtp'
    )
  end

  def send_renewal_sms(user, template, variables)
    sms_body = template.render_sms(variables)

    # Create notification for SMS tracking
    # In production, you'd dispatch via SmsNotificationJob
    Rails.logger.info "Would send renewal SMS to #{user.phone}: #{sms_body}"

    # Track the message
    MessageUsage.create!(
      user: user,
      message_type: :sms,
      status: :sent,
      sent_at: Time.current,
      cost_cents: 75, # Approx cost per SMS
      provider: 'twilio'
    )
  end

  def downgrade_to_free_plan(user)
    old_plan = user.plan

    user.update!(
      plan: :free,
      plan_active: false
    )

    # Send expiration notification
    template = EmailTemplate.find_by_type(:subscription_expired)

    if template&.active
      variables = {
        user_name: user.full_name,
        email: user.email,
        expired_plan: old_plan.humanize,
        renewal_link: "https://medivault.com/account/subscription"
      }

      # Send notification based on preference
      if user.both? || user.email_only?
        Rails.logger.info "Would send expiration email to #{user.email}"

        MessageUsage.create!(
          user: user,
          message_type: :email,
          status: :sent,
          sent_at: Time.current,
          cost_cents: 0,
          provider: 'smtp'
        )
      end
    end

    Rails.logger.info "Downgraded user #{user.id} from #{old_plan} to free plan"
  end
end
