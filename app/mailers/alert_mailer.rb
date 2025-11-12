# frozen_string_literal: true

class AlertMailer < ApplicationMailer
  def expiration_alert(alert, user, credential)
    @alert = alert
    @user = user
    @credential = credential
    @days_until_expiration = @credential.days_until_expiration

    mail(
      to: @user.email,
      subject: "⏰ Reminder: #{@credential.title} expires in #{@alert.offset_days} days"
    )
  end
end
