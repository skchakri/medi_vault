# frozen_string_literal: true

class AnalyzeCredentialJob < ApplicationJob
  queue_as :ai

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(credential_id)
    result = CertificateAnalysisTool.new.execute(credential_id: credential_id)
    Rails.logger.info "Certificate analysis complete for credential ##{credential_id}: #{result[:extracted_attributes]}"
  rescue => e
    Rails.logger.error "Certificate analysis failed for credential ##{credential_id}: #{e.message}"
    raise
  end
end
