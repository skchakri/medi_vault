# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :credential
  belongs_to :alert_type, optional: true
  has_one :user, through: :credential

  enum :status, { pending: 0, sent: 1, failed: 2, cancelled: 3 }

  validates :offset_days, :alert_date, presence: true
  validate :user_within_alert_limit, on: :create

  before_validation :set_alert_date, on: :create
  after_create :schedule_alert_notification

  scope :pending, -> { where(status: :pending) }
  scope :due_today, -> { where(status: :pending).where("alert_date <= ?", Date.today) }
  scope :upcoming, -> { where(status: :pending).where("alert_date > ?", Date.today) }

  def formatted_message
    message || "Your #{credential.title} expires in #{offset_days} days on #{credential.end_date.strftime('%B %d, %Y')}"
  end

  private

  def user_within_alert_limit
    unless credential.user.within_alert_limit?(credential)
      errors.add(:base, "Maximum alerts reached for this credential on your plan")
    end
  end

  def set_alert_date
    return if alert_date.present?
    return unless credential&.end_date && offset_days
    self.alert_date = credential.end_date - offset_days.days
  end

  def schedule_alert_notification
    return unless alert_date.present?

    if alert_date <= Date.today
      # Alert is due today or in the past, dispatch immediately
      AlertDispatcherJob.perform_later(id)
    else
      # Schedule for the alert date
      AlertDispatcherJob.set(wait_until: alert_date.to_time).perform_later(id)
    end
  end
end
