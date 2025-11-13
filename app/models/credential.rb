# frozen_string_literal: true

class Credential < ApplicationRecord
  # Associations
  belongs_to :user, counter_cache: true
  has_many :alerts, dependent: :destroy
  has_many :share_links, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one_attached :file

  # Enums
  enum :status, {
    pending: 0,
    active: 1,
    expiring_soon: 2,
    expired: 3
  }

  # Validations
  validates :title, presence: true
  validates :file, presence: true, on: :create, if: -> { Rails.env.production? || (!Rails.env.test? && file.attached?) }
  validate :user_within_credential_limit, on: :create
  validate :end_date_after_start_date

  # Callbacks
  after_create :schedule_ai_extraction
  after_create :create_default_alerts
  after_save :update_status_based_on_expiration
  before_destroy :decrement_user_counter

  # Scopes
  scope :active, -> { where(status: [:active, :expiring_soon]) }
  scope :expiring_soon, -> { where("end_date <= ? AND end_date > ?", 30.days.from_now, Date.today) }
  scope :expired, -> { where("end_date <= ?", Date.today) }
  scope :by_expiration, -> { order(end_date: :asc) }

  # Instance Methods
  def days_until_expiration
    return nil unless end_date
    (end_date - Date.today).to_i
  end

  def expiring_soon?
    days = days_until_expiration
    days && days <= 30 && days > 0
  end

  def expired?
    end_date && end_date <= Date.today
  end

  def file_url
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) if file.attached?
  end

  def file_size_mb
    (file.byte_size / 1.megabyte.to_f).round(2) if file.attached?
  end

  def displayable_start_date
    start_date&.strftime("%B %d, %Y") || "N/A"
  end

  def displayable_end_date
    end_date&.strftime("%B %d, %Y") || "N/A"
  end

  private

  def user_within_credential_limit
    unless user.within_credential_limit?
      errors.add(:base, "You've reached your credential limit (#{user.max_credentials}). Please upgrade your plan.")
    end
  end

  def end_date_after_start_date
    return unless start_date && end_date
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def schedule_ai_extraction
    CredentialExtractionJob.perform_later(id) if file.attached?
  end

  def create_default_alerts
    return unless end_date.present?

    # Get active alert types applicable to user's plan
    applicable_alert_types = AlertType.active
      .where("user_plans IS NULL OR user_plans @> ?", [user.plan].to_json)
      .order(priority: :asc)

    applicable_alert_types.each do |alert_type|
      alert_date = end_date - alert_type.offset_days.days
      next if alert_date < Date.today

      alerts.create!(
        alert_type: alert_type,
        offset_days: alert_type.offset_days,
        alert_date: alert_date,
        message: "Your #{title} expires in #{alert_type.offset_days} days"
      )
    end
  end

  def update_status_based_on_expiration
    return unless end_date.present?

    new_status = if expired?
                   :expired
                 elsif expiring_soon?
                   :expiring_soon
                 else
                   :active
                 end

    update_column(:status, new_status) if status != new_status
  end

  def decrement_user_counter
    user.decrement!(:credentials_count) if user.credentials_count > 0
  end
end
