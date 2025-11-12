# frozen_string_literal: true

class CredentialExtractionJob < ApplicationJob
  queue_as :ai

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(credential_id)
    credential = Credential.find(credential_id)

    result = CredentialExtractionService.call(credential: credential)

    if result.success?
      Rails.logger.info "Successfully extracted data for credential #{credential_id}"
    else
      Rails.logger.error "Failed to extract data for credential #{credential_id}: #{result.errors.join(', ')}"
      raise "Extraction failed: #{result.errors.join(', ')}"
    end
  end
end
