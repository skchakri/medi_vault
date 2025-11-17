class EmailTemplate < ApplicationRecord
  # Enums
  enum :template_type, {
    welcome: 0,
    confirmation_instructions: 1,
    reset_password_instructions: 2,
    email_changed: 3,
    password_change: 4,
    unlock_instructions: 5,
    alert_expiration: 6,
    subscription_renewal: 7,
    subscription_expired: 8
  }

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :template_type, presence: true
  validates :subject, presence: true
  validates :html_body, presence: true
  validate :sms_body_length

  # Class methods for template management
  def self.find_by_type(template_type)
    where(template_type: template_type, active: true).first
  end

  # Instance methods
  def render_html(variables = {})
    interpolate_template(html_body, variables)
  end

  def render_text(variables = {})
    interpolate_template(text_body, variables)
  end

  def render_subject(variables = {})
    interpolate_template(subject, variables)
  end

  def render_sms(variables = {})
    interpolate_template(sms_body, variables)
  end

  def has_sms_template?
    sms_body.present?
  end

  private

  def sms_body_length
    return unless sms_body.present?

    # SMS limit is typically 160 characters for a single message
    # We'll allow up to 320 characters (2 messages) but warn if over 160
    if sms_body.length > 320
      errors.add(:sms_body, "is too long (maximum is 320 characters for 2 SMS messages)")
    end
  end

  def interpolate_template(template_string, variables = {})
    return template_string unless template_string.present?

    result = template_string
    variables.each do |key, value|
      # Support both {{variable}} and <%= variable %> syntax
      result = result.gsub("{{#{key}}}", value.to_s)
      result = result.gsub("<%= #{key} %>", value.to_s)
    end
    result
  end
end
