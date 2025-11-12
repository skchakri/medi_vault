class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    template = EmailTemplate.find_by_type(:welcome) || EmailTemplate.find_by_type("welcome:0")

    if template
      @subject = template.render_subject(user_name: @user.full_name, email: @user.email)
      @html_body = template.render_html(user_name: @user.full_name, email: @user.email)
      @text_body = template.render_text(user_name: @user.full_name, email: @user.email)

      mail(
        to: @user.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default template
      mail(
        to: @user.email,
        subject: "Welcome to MediVault, {{user_name}}!".gsub("{{user_name}}", @user.first_name)
      )
    end
  end
end
