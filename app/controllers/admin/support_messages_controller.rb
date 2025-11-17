# frozen_string_literal: true

module Admin
  class SupportMessagesController < AdminController
    before_action :set_conversation, only: [:show, :reply]

    def index
      @filter = params[:filter] || 'all'

      @conversations = case @filter
                       when 'unread'
                         SupportMessage.conversations_for_admin.joins(:replies).merge(SupportMessage.user_messages.unread).distinct
                       when 'unanswered'
                         SupportMessage.conversations_for_admin.left_joins(:replies)
                                       .where(replies_support_messages: { id: nil })
                       else
                         SupportMessage.conversations_for_admin
                       end

      # FIFO sorting - oldest first
      @conversations = @conversations.order(created_at: :asc).page(params[:page]).per(20)
      @unread_count = SupportMessage.unread_count_for_admin
      @unanswered_count = SupportMessage.root_messages.left_joins(:replies).where(replies_support_messages: { id: nil }).count
    end

    def show
      @messages = @conversation.conversation_thread
      @new_reply = SupportMessage.new(parent: @conversation, is_admin_response: true)

      # Mark user messages as read
      @messages.select { |m| !m.is_admin_response? && m.unread? }.each(&:mark_as_read!)
    end

    def reply
      @reply = SupportMessage.new(reply_params)
      @reply.user = @conversation.user
      @reply.is_admin_response = true
      @reply.parent = @conversation.root_message

      if @reply.save
        # Notify user of admin response
        notify_user_of_reply(@reply)

        redirect_to admin_support_message_path(@conversation), notice: 'Reply sent successfully.'
      else
        @messages = @conversation.conversation_thread
        @new_reply = @reply
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_conversation
      @conversation = SupportMessage.root_messages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_support_messages_path, alert: 'Conversation not found.'
    end

    def reply_params
      params.require(:support_message).permit(:message)
    end

    def notify_user_of_reply(reply)
      user = reply.user

      # Send notification based on user preference
      if user.notification_email && (user.both? || user.email_only?)
        UserMailer.support_message_reply(user, reply).deliver_later
      end

      # Note: SMS notification can be added here if needed
      # For support chat, email is typically more appropriate as messages can be longer
    end
  end
end
