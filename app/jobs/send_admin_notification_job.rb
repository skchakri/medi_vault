# frozen_string_literal: true

class SendAdminNotificationJob < ApplicationJob
  queue_as :default

  # Discard the job if the admin or message has been deleted
  discard_on ActiveRecord::RecordNotFound

  def perform(admin_id, support_message_id)
    admin = User.find(admin_id)
    message = SupportMessage.find(support_message_id)
    AdminMailer.new_support_message(admin, message).deliver_now
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "Record not found (#{e.message}), skipping admin notification"
  end
end
