# frozen_string_literal: true

module Account
  class SupportMessagesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_conversation, only: [:show]

    def index
      @conversations = SupportMessage.conversations_for_user(current_user)
                                     .page(params[:page])
                                     .per(20)
      @unread_count = SupportMessage.unread_count_for_user(current_user)

      respond_to do |format|
        format.html
        format.json do
          messages = current_user.support_messages.order(created_at: :asc).map do |msg|
            {
              id: msg.id,
              message: msg.message,
              from_admin: msg.is_admin_response,
              created_at: msg.created_at,
              read_at: msg.read_at
            }
          end
          render json: { messages: messages }
        end
      end
    end

    def show
      @messages = @conversation.conversation_thread
      @new_message = SupportMessage.new(parent: @conversation)

      # Mark admin responses as read
      @messages.select { |m| m.is_admin_response? && m.unread? }.each(&:mark_as_read!)
    end

    def new
      @message = current_user.support_messages.build
    end

    def create
      @message = current_user.support_messages.build(message_params)
      @message.is_admin_response = false

      respond_to do |format|
        if @message.save
          # Notify admin of new message
          notify_admin_of_new_message(@message)

          format.html { redirect_to account_support_message_path(@message.root_message), notice: 'Your message has been sent. We will respond shortly.' }
          format.json { render json: { success: true, message: @message }, status: :created }
        else
          format.html do
            if @message.parent_id.present?
              # This is a reply, redirect back to conversation
              @conversation = SupportMessage.find(@message.parent_id).root_message
              @messages = @conversation.conversation_thread
              @new_message = @message
              render :show, status: :unprocessable_entity
            else
              # This is a new conversation
              render :new, status: :unprocessable_entity
            end
          end
          format.json { render json: { success: false, errors: @message.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_conversation
      @conversation = current_user.support_messages.root_messages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to account_support_messages_path, alert: 'Conversation not found.'
    end

    def message_params
      params.require(:support_message).permit(:body, :message, :parent_id)
    end

    def notify_admin_of_new_message(message)
      # Send email to admin about new support message
      admin_users = User.admins
      admin_users.each do |admin|
        AdminMailer.new_support_message(admin, message).deliver_later
      end
    end
  end
end
