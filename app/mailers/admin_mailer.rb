class AdminMailer < ApplicationMailer
  def new_support_message(admin, message)
    @admin = admin
    @message = message
    @user = message.user
    @conversation_url = Rails.application.routes.url_helpers.admin_support_message_url(
      message.root_message,
      host: ENV.fetch('APP_HOST', 'localhost:3000')
    )

    mail(
      to: @admin.email,
      subject: "New Support Message from #{@user.full_name}"
    )
  end
end
