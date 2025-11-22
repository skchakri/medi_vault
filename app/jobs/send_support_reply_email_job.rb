# frozen_string_literal: true

class SendSupportReplyEmailJob < ApplicationJob
  queue_as :default

  # Discard the job if the user or message has been deleted
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id, reply_message_id)
    user = User.find(user_id)
    reply_message = SupportMessage.find(reply_message_id)
    UserMailer.support_message_reply(user, reply_message).deliver_now
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "Record not found (#{e.message}), skipping support reply email"
  end
end
