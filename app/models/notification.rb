# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :credential, optional: true

  enum :channel, { email: 0, sms: 1, in_app: 2 }
  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :channel, presence: true

  scope :unread, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc).limit(50) }

  def mark_as_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  def mark_as_failed!(error)
    update!(status: :failed, error_text: error)
  end
end
