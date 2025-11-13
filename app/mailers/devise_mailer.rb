# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  helper :application
  include Rails.application.routes.url_helpers

  # Use the database-backed email templates for Devise emails

  def confirmation_instructions(record, token, opts = {})
    @user = record
    @token = token
    @confirmation_url = user_confirmation_url(confirmation_token: token)

    # Try to load template from database
    template = EmailTemplate.find_by_type(:confirmation_instructions)

    if template
      @subject = template.render_subject(
        user_name: @user.full_name,
        email: @user.email
      )
      @html_body = template.render_html(
        user_name: @user.full_name,
        email: @user.email,
        confirmation_link: @confirmation_url
      )
      @text_body = template.render_text(
        user_name: @user.full_name,
        email: @user.email,
        confirmation_link: @confirmation_url
      )

      mail(
        to: record.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default Devise behavior
      super
    end
  end

  def reset_password_instructions(record, token, opts = {})
    @user = record
    @token = token
    @reset_password_url = edit_user_password_url(reset_password_token: token)

    # Try to load template from database
    template = EmailTemplate.find_by_type(:reset_password_instructions)

    if template
      @subject = template.render_subject(user_name: @user.full_name)
      @html_body = template.render_html(
        user_name: @user.full_name,
        email: @user.email,
        reset_link: @reset_password_url
      )
      @text_body = template.render_text(
        user_name: @user.full_name,
        email: @user.email,
        reset_link: @reset_password_url
      )

      mail(
        to: record.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default Devise behavior
      super
    end
  end

  def email_changed(record, opts = {})
    @user = record
    template = EmailTemplate.find_by_type(:email_changed)

    if template
      @subject = template.render_subject(user_name: @user.full_name)
      @html_body = template.render_html(
        user_name: @user.full_name,
        email: @user.email
      )
      @text_body = template.render_text(
        user_name: @user.full_name,
        email: @user.email
      )

      mail(
        to: record.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default Devise behavior
      super
    end
  end

  def unlock_instructions(record, token, opts = {})
    @user = record
    @token = token
    @unlock_url = user_unlock_url(unlock_token: token)

    template = EmailTemplate.find_by_type(:unlock_instructions)

    if template
      @subject = template.render_subject(user_name: @user.full_name)
      @html_body = template.render_html(
        user_name: @user.full_name,
        email: @user.email,
        unlock_link: @unlock_url
      )
      @text_body = template.render_text(
        user_name: @user.full_name,
        email: @user.email,
        unlock_link: @unlock_url
      )

      mail(
        to: record.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default Devise behavior
      super
    end
  end

  def password_change(record, opts = {})
    @user = record
    template = EmailTemplate.find_by_type(:password_change)

    if template
      @subject = template.render_subject(user_name: @user.full_name)
      @html_body = template.render_html(
        user_name: @user.full_name,
        email: @user.email
      )
      @text_body = template.render_text(
        user_name: @user.full_name,
        email: @user.email
      )

      mail(
        to: record.email,
        subject: @subject,
        body: @html_body,
        content_type: "text/html; charset=UTF-8"
      )
    else
      # Fallback to default Devise behavior
      super
    end
  end
end
