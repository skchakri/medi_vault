# frozen_string_literal: true

# Basic RubyLLM configuration. Provider-specific credentials (OpenAI, Ollama, etc.)
# are injected at runtime inside CertificateAnalysisTool to support dynamic updates
# via ApiSetting without needing to restart the app.
RubyLLM.configure do |config|
  config.logger = Rails.logger
  config.request_timeout = 180
  config.log_level = Rails.logger.level
end
