# frozen_string_literal: true

class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  # Discard the job if the user has been deleted
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome_email(user).deliver_now
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "User ##{user_id} not found, skipping welcome email"
  end
end
