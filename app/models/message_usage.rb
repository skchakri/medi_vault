class MessageUsage < ApplicationRecord
  belongs_to :user

  # Enums
  enum :message_type, { email: 0, sms: 1 }
  enum :status, { pending: 0, sent: 1, failed: 2 }

  # Validations
  validates :message_type, presence: true
  validates :status, presence: true

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :in_date_range, ->(start_date, end_date) { where(sent_at: start_date..end_date) }
  scope :this_month, -> { where('sent_at >= ?', Time.current.beginning_of_month) }
  scope :last_30_days, -> { where('sent_at >= ?', 30.days.ago) }

  # Class methods
  def self.total_cost
    sum(:cost_cents) / 100.0
  end

  def self.count_by_type
    group(:message_type).count
  end

  def self.count_by_status
    group(:status).count
  end

  # Instance methods
  def cost_dollars
    (cost_cents || 0) / 100.0
  end

  def mark_as_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  def mark_as_failed!(error)
    update!(status: :failed, error_message: error, sent_at: Time.current)
  end
end
