# frozen_string_literal: true

module Admin
  class SettingsController < AdminController
    def show
      @api_settings = ApiSetting.all.order(:key)

      # Group settings by section for the UI
      @api_keys = @api_settings.select { |s| ['npi_api_url'].include?(s.key) }
      @ai_models = @api_settings.select { |s| ['openai_api_key', 'openai_model', 'ollama_url', 'ollama_model'].include?(s.key) }
      @notifications = @api_settings.select { |s| ['twilio_sid', 'twilio_token', 'twilio_from', 'smtp_host', 'smtp_port', 'smtp_username', 'smtp_password'].include?(s.key) }
      @oauth = @api_settings.select { |s| ['google_oauth_client_id', 'google_oauth_client_secret', 'google_oauth_redirect_uri'].include?(s.key) }
    end

    def update
      settings_updated = true

      params[:settings]&.each do |key, value|
        next if value.blank?

        setting = ApiSetting.find_or_initialize_by(key: key)

        # Determine if this should be encrypted
        encrypted_keys = ['openai_api_key', 'twilio_token', 'smtp_password', 'google_oauth_client_secret', 'stripe_secret_key']

        if encrypted_keys.include?(key)
          setting.encrypted_value = value
          setting.value = nil
        else
          setting.value = value
          setting.encrypted_value = nil
        end

        unless setting.save
          settings_updated = false
          break
        end
      end

      if settings_updated
        redirect_to admin_settings_path, notice: 'Settings updated successfully.'
      else
        redirect_to admin_settings_path, alert: 'Error updating settings.'
      end
    end

    private

    def setting_params
      params.require(:settings).permit(
        :npi_api_url,
        :openai_api_key, :openai_model,
        :ollama_url, :ollama_model,
        :twilio_sid, :twilio_token, :twilio_from,
        :smtp_host, :smtp_port, :smtp_username, :smtp_password,
        :google_oauth_client_id, :google_oauth_client_secret, :google_oauth_redirect_uri,
        :stripe_publishable_key, :stripe_secret_key
      )
    end
  end
end
