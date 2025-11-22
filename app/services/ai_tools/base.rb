# frozen_string_literal: true

module AiTools
  class Base < RubyLLM::Tool
    private

    ProviderConfig = Struct.new(:provider, :model, :apply!)

    def provider_env(key)
      ENV[key]&.presence
    end

    def resolve_provider_configuration(preferred_model: nil)
      openai_key = ApiSetting.get('openai_api_key').presence || provider_env('OPENAI_API_KEY')
      if openai_key.present?
        model = preferred_model || ApiSetting.get('openai_model').presence || provider_env('OPENAI_MODEL') || 'gpt-4o-mini'
        return ProviderConfig.new(
          :openai,
          model,
          proc do |config|
            config.openai_api_key = openai_key
            openai_base = provider_env('OPENAI_API_BASE')
            config.openai_api_base = openai_base if openai_base.present?
            config.default_model = model
          end
        )
      end

      ollama_url = ApiSetting.get('ollama_url').presence || provider_env('OLLAMA_URL')
      if ollama_url.present?
        model = preferred_model || ApiSetting.get('ollama_model').presence || provider_env('OLLAMA_MODEL') || 'llama3.2'
        return ProviderConfig.new(
          :ollama,
          model,
          proc do |config|
            config.ollama_api_base = ollama_url
            config.default_model = model
          end
        )
      end

      raise 'No LLM provider configured. Please set OpenAI or Ollama credentials.'
    end

    def build_context(provider_config)
      RubyLLM.context do |config|
        provider_config.apply!(config)
      end
    end

    def attachable_file(blob_id: nil, path: nil)
      if blob_id.present?
        blob = ActiveStorage::Blob.find(blob_id)
        return ActiveStorage::Blob.service.send(:path_for, blob.key) if blob.service.is_a?(ActiveStorage::Service::DiskService)
        tmp = Tempfile.new(["ai_tool", blob.filename.extension_with_delimiter])
        tmp.binmode
        tmp.write(blob.download)
        tmp.rewind
        tmp
      elsif path.present?
        Pathname.new(path)
      end
    end
  end
end
