# frozen_string_literal: true

class CredentialMailer < ApplicationMailer
  def bulk_share(credentials:, recipient_email:, sender:, message: nil, pdf_path:)
    @credentials = credentials
    @sender = sender
    @message = message
    @recipient_email = recipient_email

    attachments["credentials_bundle.pdf"] = File.read(pdf_path)

    mail(
      to: recipient_email,
      subject: "#{sender.full_name} shared #{credentials.count} credential(s) with you"
    )
  end
end
