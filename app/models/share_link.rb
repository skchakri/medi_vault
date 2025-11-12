# frozen_string_literal: true

class ShareLink < ApplicationRecord
  belongs_to :credential

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :active, -> { where("expires_at > ? AND (used_at IS NULL OR one_time = false)", Time.current) }
  scope :expired, -> { where("expires_at <= ? OR (one_time = true AND used_at IS NOT NULL)", Time.current) }

  def active?
    expires_at > Time.current && (used_at.nil? || !one_time?)
  end

  def record_access!
    update!(used_at: Time.current)
  end

  def share_url
    Rails.application.routes.url_helpers.share_url(token, host: ENV.fetch('APP_HOST', 'localhost:3000'))
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= 24.hours.from_now
  end
end
