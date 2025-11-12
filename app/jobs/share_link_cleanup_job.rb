# frozen_string_literal: true

class ShareLinkCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_links = ShareLink.expired
    count = expired_links.count

    expired_links.destroy_all

    Rails.logger.info "Cleaned up #{count} expired share links"
  end
end
