# frozen_string_literal: true

require 'ruby_llm/schema'

class CertificateAnalysisSchema < RubyLLM::Schema
  string :title, description: "Official credential name from the certificate"

  any_of :start_date, description: "Issue or start date in YYYY-MM-DD" do
    string pattern: '\\d{4}-\\d{2}-\\d{2}'
    null
  end

  any_of :end_date, description: "Expiration or renewal date in YYYY-MM-DD" do
    string pattern: '\\d{4}-\\d{2}-\\d{2}'
    null
  end

  any_of :issuing_organization, description: "Organization or authority that issued the credential" do
    string
    null
  end

  any_of :credential_number, description: "Credential/license/certificate identifier" do
    string
    null
  end

  any_of :document_summary, description: "Short summary of the certificate contents" do
    string
    null
  end

  array :warnings, of: :string, required: false, description: "Important warnings found on the document"
end

class CertificateAnalysisTool < RubyLLM::Tool
  description "Analyzes professional certificates with RubyLLM and extracts structured metadata"

  param :credential_id, type: 'integer', desc: 'Credential ID to analyze'

  def execute(credential_id:)
    credential = Credential.find(credential_id)
    raise ArgumentError, 'Credential does not have a file attached' unless credential.file.attached?

    provider = resolve_provider_configuration
    data = analyze_with_ruby_llm(credential, provider)
    persist_analysis!(credential, data)

    {
      credential_id: credential.id,
      extracted_attributes: data
    }
  end

  private

  ProviderConfig = Struct.new(:provider, :model, :apply!)

  def provider_env(key)
    ENV[key]&.presence
  end

  def resolve_provider_configuration
    openai_key = ApiSetting.get('openai_api_key').presence || provider_env('OPENAI_API_KEY')
    if openai_key.present?
      model = ApiSetting.get('openai_model').presence || provider_env('OPENAI_MODEL') || 'gpt-4o-mini'
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
      model = ApiSetting.get('ollama_model').presence || provider_env('OLLAMA_MODEL') || 'llama3.2'
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

  def analyze_with_ruby_llm(credential, provider)
    context = RubyLLM.context do |config|
      provider.apply!(config)
    end

    chat = context.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
                 .with_instructions(system_prompt)
                 .with_schema(CertificateAnalysisSchema)
                 .with_temperature(0.1)

    response = chat.ask(user_prompt(credential), with: credential.file)
    normalize_response(response.content)
  end

  def user_prompt(credential)
    <<~PROMPT
      Analyze the attached professional credential/certificate/license.

      Existing details from the database (may be incomplete):
      - Title: #{credential.title.presence || 'Unknown'}
      - Notes: #{credential.notes.presence || 'None provided'}

      Extract the official credential title, issuing organization, credential/license number, and start/end dates.
      Dates must use the YYYY-MM-DD format. If only month/year is present, assume the first day of that month.
      If the data is missing or unclear, return null for that field.

      Provide a concise summary of the certificate if possible and include any warnings (e.g., expired, missing signatures).
    PROMPT
  end

  def system_prompt
    <<~PROMPT
      You are a meticulous assistant that reads certificates and returns structured metadata.
      Use the provided schema and return clean, normalized values.
      Titles should be concise (e.g., "Medical License"), and organizations should use their official names.
      Prefer ISO-8601 format for dates, defaulting to the first day of the month when only MM/YYYY is present.
      Use null for any field you cannot find.
    PROMPT
  end

  def persist_analysis!(credential, data)
    credential.update!(
      title: data[:title].presence || credential.title,
      start_date: parse_date(data[:start_date]),
      end_date: parse_date(data[:end_date]),
      ai_extracted_json: data.to_h,
      ai_processed: true,
      ai_processed_at: Time.current
    )
  end

  def normalize_response(payload)
    data = case payload
           when Hash
             payload
           when String
             parse_json_string(payload)
           else
             payload.respond_to?(:to_h) ? payload.to_h : {}
           end

    normalized = HashWithIndifferentAccess.new(data)
    normalized[:warnings] ||= []
    normalized
  end

  def parse_json_string(payload)
    JSON.parse(payload)
  rescue JSON::ParserError
    { title: payload }
  end

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str)
  rescue ArgumentError
    nil
  end
end
