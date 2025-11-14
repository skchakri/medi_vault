# frozen_string_literal: true

class ApiSetting < ApplicationRecord
  # Lockbox encryption for sensitive values
  encrypts :encrypted_value, key: :lockbox_master_key

  validates :key, presence: true, uniqueness: true

  scope :enabled, -> { where(enabled: true) }

  KEYS = {
    npi_api_url: 'NPI Registry API URL',
    npi_api_version: 'NPI Registry API Version',
    openai_api_key: 'OpenAI API Key',
    openai_model: 'OpenAI Default Model',
    ollama_url: 'Ollama API URL',
    ollama_model: 'Ollama Default Model',
    twilio_sid: 'Twilio Account SID',
    twilio_token: 'Twilio Auth Token',
    twilio_from: 'Twilio From Number'
  }.freeze

  def self.get(key)
    find_by(key: key)&.decrypted_value
  end

  def self.set(key, value, encrypt: false)
    setting = find_or_initialize_by(key: key)
    if encrypt
      setting.encrypted_value = value
      setting.value = nil
    else
      setting.value = value
      setting.encrypted_value = nil
    end
    setting.save!
    setting
  end

  def decrypted_value
    encrypted_value.presence || value
  end

  private

  def lockbox_master_key
    ENV['LOCKBOX_MASTER_KEY'] || raise('LOCKBOX_MASTER_KEY not set')
  end
end
