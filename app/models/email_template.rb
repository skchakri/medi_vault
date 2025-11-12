class EmailTemplate < ApplicationRecord
  # Enums
  enum :template_type, { welcome: 0, confirmation_instructions: 1, reset_password_instructions: 2, email_changed: 3, password_change: 4, unlock_instructions: 5 }

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :template_type, presence: true
  validates :subject, presence: true
  validates :html_body, presence: true

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

  private

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
