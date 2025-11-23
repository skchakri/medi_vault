# frozen_string_literal: true

class CredentialBulkShareJob < ApplicationJob
  queue_as :default

  def perform(credential_ids:, recipient_email:, sender_id:, message: nil)
    credentials = Credential.where(id: credential_ids).includes(:file_attachment)
    sender = User.find(sender_id)

    # Bundle credentials into a single PDF
    pdf_path = CredentialPdfBundler.new(credentials).bundle

    # Send email with bundled PDF
    CredentialMailer.bulk_share(
      credentials: credentials,
      recipient_email: recipient_email,
      sender: sender,
      message: message,
      pdf_path: pdf_path
    ).deliver_now

    # Clean up temp file
    File.delete(pdf_path) if File.exist?(pdf_path)
  rescue => e
    Rails.logger.error "Failed to bulk share credentials: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
