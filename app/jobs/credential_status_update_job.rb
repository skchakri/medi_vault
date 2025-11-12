# frozen_string_literal: true

class CredentialStatusUpdateJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting credential status update job"

    updated_count = 0

    Credential.find_each do |credential|
      old_status = credential.status
      credential.send(:update_status_based_on_expiration)

      if credential.status != old_status
        updated_count += 1
        Rails.logger.info "Updated credential #{credential.id} from #{old_status} to #{credential.status}"
      end
    end

    Rails.logger.info "Credential status update completed. Updated #{updated_count} credentials."
  end
end
