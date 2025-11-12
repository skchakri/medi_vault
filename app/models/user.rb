# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable

  # Associations
  has_many :credentials, dependent: :destroy
  has_many :alerts, through: :credentials
  has_many :notifications, dependent: :destroy
  has_many :share_links, through: :credentials
  has_many :llm_requests, dependent: :nullify
  has_one_attached :avatar

  # Enums
  enum :role, { user: 0, admin: 1 }
  enum :plan, { free: 0, basic: 1, pro: 2 }

  # Validations
  validates :first_name, :last_name, presence: true
  validates :npi, uniqueness: { allow_nil: true }, format: { with: /\A\d{10}\z/, message: "must be 10 digits", allow_blank: true }
  validate :phone_number_valid, if: -> { phone.present? }

  # Callbacks
  before_create :set_default_plan
  after_create :send_welcome_email

  # Scopes
  scope :active_users, -> { where("trial_ends_at > ? OR plan_active = ?", Time.current, true) }
  scope :admins, -> { where(role: :admin) }
  scope :trial_ending_soon, -> { where("trial_ends_at <= ? AND trial_ends_at > ?", 3.days.from_now, Time.current) }

  # Instance Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def npi_verified?
    npi_verified_at.present?
  end

  def within_credential_limit?
    case plan
    when "free"
      credentials_count < 3
    when "basic"
      credentials_count < 10
    when "pro"
      credentials_count < 30
    else
      false
    end
  end

  def max_credentials
    case plan
    when "free" then 3
    when "basic" then 10
    when "pro" then 30
    else 0
    end
  end

  def within_alert_limit?(credential)
    return true if pro?

    max_alerts = case plan
                 when "free" then 1
                 when "basic" then 3
                 else 0
                 end

    credential.alerts.count < max_alerts
  end

  def max_alerts_per_credential
    case plan
    when "free" then 1
    when "basic" then 3
    when "pro" then Float::INFINITY
    else 0
    end
  end

  def can_use_sms?
    pro? && phone.present? && phone_verified?
  end

  def active_plan?
    plan_active? || (trial_ends_at.present? && trial_ends_at > Time.current)
  end

  private

  def set_default_plan
    self.plan ||= :free
    self.trial_ends_at ||= 14.days.from_now
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def phone_number_valid
    parsed_phone = Phonelib.parse(phone)
    unless parsed_phone.valid?
      errors.add(:phone, "is not a valid phone number")
    end
  end
end
