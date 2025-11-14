# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable, :omniauthable,
         omniauth_providers: [:google_oauth2]

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
  validate :password_required, on: :create, unless: :oauth_user?

  # Callbacks
  before_create :set_default_plan
  after_create :send_welcome_email

  # Scopes
  scope :active_users, -> { where("trial_ends_at > ? OR plan_active = ?", Time.current, true) }
  scope :admins, -> { where(role: :admin) }
  scope :trial_ending_soon, -> { where("trial_ends_at <= ? AND trial_ends_at > ?", 3.days.from_now, Time.current) }

  # Class Methods
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create! do |new_user|
      new_user.email = auth.info.email
      new_user.first_name = auth.info.first_name || auth.info.name.split.first rescue "User"
      new_user.last_name = auth.info.last_name || auth.info.name.split.last rescue ""
      new_user.avatar_url = auth.info.image
      new_user.password = SecureRandom.hex(16)
      new_user.password_confirmation = new_user.password
      new_user.confirmed_at = Time.current
      new_user.provider = auth.provider
      new_user.uid = auth.uid
    end

    # Update OAuth token and expiration
    attrs = { oauth_token: auth.credentials.token }
    attrs[:oauth_expires_at] = Time.at(auth.credentials.expires_at) if auth.credentials.expires_at.present?
    user.update(attrs)

    user
  end

  # Instance Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def npi_verified?
    npi_verified_at.present?
  end

  def individual_npi?
    npi_enumeration_type == "NPI-1"
  end

  def organization_npi?
    npi_enumeration_type == "NPI-2"
  end

  def formatted_mailing_address
    format_address(mailing_address)
  end

  def formatted_practice_address
    format_address(practice_address)
  end

  def formatted_location_address
    format_address(location_address)
  end

  def lookup_and_populate_npi(npi_number)
    result = NpiLookupService.call(user: self, npi: npi_number)

    if result.success?
      result.data
    else
      { errors: result.errors }
    end
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

  # NPI-related helper methods
  def full_name_with_prefix
    parts = []
    parts << name_prefix if name_prefix.present?
    parts << first_name
    parts << middle_name if middle_name.present?
    parts << last_name
    parts << name_suffix if name_suffix.present?
    parts.join(" ")
  end

  def primary_taxonomy
    return nil if taxonomies.blank?
    taxonomies.find { |t| t["primary"] == true } || taxonomies.first
  end

  def formatted_taxonomies
    return [] if taxonomies.blank?
    taxonomies.map do |t|
      {
        code: t["code"],
        description: t["desc"],
        state: t["state"],
        license: t["license"],
        primary: t["primary"]
      }
    end
  end

  def formatted_identifiers
    return [] if identifiers.blank?
    identifiers.map do |i|
      {
        type: i["desc"],
        identifier: i["identifier"],
        code: i["code"],
        issuer: i["issuer"],
        state: i["state"]
      }
    end
  end

  def active_npi_status?
    npi_status == "A"
  end

  def npi_status_text
    case npi_status
    when "A" then "Active"
    when "D" then "Deactivated"
    else "Unknown"
    end
  end

  def gender_display
    case gender
    when "M" then "Male"
    when "F" then "Female"
    when "X" then "Other"
    else gender
    end
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

  def oauth_user?
    provider.present?
  end

  def password_required
    return if password.present? || password_confirmation.present?
    errors.add(:password, "can't be blank") unless oauth_user?
  end

  def password_required?
    # Skip password validation if we're updating without password
    return false if @updating_password == false

    # For new records, require password unless OAuth user
    new_record? && !oauth_user?
  end

  def format_address(address_hash)
    return nil if address_hash.blank?

    parts = []
    parts << address_hash["address_1"] if address_hash["address_1"].present?
    parts << address_hash["address_2"] if address_hash["address_2"].present?

    city_state_zip = []
    city_state_zip << address_hash["city"] if address_hash["city"].present?
    city_state_zip << address_hash["state"] if address_hash["state"].present?
    city_state_zip << address_hash["postal_code"] if address_hash["postal_code"].present?

    parts << city_state_zip.join(", ") if city_state_zip.any?
    parts << address_hash["country_code"] if address_hash["country_code"].present? && address_hash["country_code"] != "US"

    parts.join("\n")
  end
end
