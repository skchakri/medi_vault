# frozen_string_literal: true

require "ruby_llm/schema"
require "pdf-reader"

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

  array :suggested_tags, of: :string, required: false, description: "Relevant tags/categories for this credential (e.g., 'Medical License', 'Nursing', 'CPR', 'Board Certification')"
end

class CertificateAnalysisTool < RubyLLM::Tool
  description "Analyzes professional certificates with RubyLLM and extracts structured metadata"

  param :credential_id, type: "integer", desc: "Credential ID to analyze"

  def execute(credential_id:)
    credential = Credential.find(credential_id)
    raise ArgumentError, "Credential does not have a file attached" unless credential.file.attached?

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
    # First check if there's a default AI model
    default_ai_model = AiModel.default_model
    if default_ai_model
      if default_ai_model.provider == "openai"
        openai_key = ApiSetting.get("openai_api_key").presence || provider_env("OPENAI_API_KEY")
        if openai_key.present?
          return ProviderConfig.new(
            :openai,
            default_ai_model.model_identifier,
            proc do |config|
              config.openai_api_key = openai_key
              openai_base = provider_env("OPENAI_API_BASE")
              config.openai_api_base = openai_base if openai_base.present?
              config.default_model = default_ai_model.model_identifier
            end
          )
        end
      elsif default_ai_model.provider == "ollama"
        ollama_url = ApiSetting.get("ollama_url").presence || provider_env("OLLAMA_URL")
        if ollama_url.present?
          return ProviderConfig.new(
            :ollama,
            default_ai_model.model_identifier,
            proc do |config|
              config.ollama_api_base = ollama_url
              config.default_model = default_ai_model.model_identifier
            end
          )
        end
      end
    end

    # Fall back to ApiSetting and environment variables
    openai_key = ApiSetting.get("openai_api_key").presence || provider_env("OPENAI_API_KEY")
    if openai_key.present?
      model = ApiSetting.get("openai_model").presence || provider_env("OPENAI_MODEL") || "gpt-4o-mini"
      return ProviderConfig.new(
        :openai,
        model,
        proc do |config|
          config.openai_api_key = openai_key
          openai_base = provider_env("OPENAI_API_BASE")
          config.openai_api_base = openai_base if openai_base.present?
          config.default_model = model
        end
      )
    end

    ollama_url = ApiSetting.get("ollama_url").presence || provider_env("OLLAMA_URL")
    if ollama_url.present?
      model = ApiSetting.get("ollama_model").presence || provider_env("OLLAMA_MODEL") || "llama3.2"
      return ProviderConfig.new(
        :ollama,
        model,
        proc do |config|
          config.ollama_api_base = ollama_url
          config.default_model = model
        end
      )
    end

    raise "No LLM provider configured. Please set OpenAI or Ollama credentials."
  end

  def analyze_with_ruby_llm(credential, provider)
    context = RubyLLM.context do |config|
      provider.apply!.call(config)
    end

    chat = context.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
                 .with_instructions(system_prompt)
                 .with_temperature(0.1)

    # Only use structured outputs for OpenAI models that support it
    # Ollama and older OpenAI models don't support json_schema response format
    if supports_structured_outputs?(provider)
      chat = chat.with_schema(CertificateAnalysisSchema)
    end
    # For other providers, rely on prompt instructions to return JSON
    # The normalize_response method will parse the JSON string response

    response = if pdf_file?(credential)
      # Extract text from PDF and send as text
      pdf_text = extract_pdf_text(credential)
      chat.ask(user_prompt_with_text(credential, pdf_text))
    else
      # For images, send the file directly
      chat.ask(user_prompt(credential), with: credential.file)
    end

    normalize_response(response.content)
  end

  def supports_structured_outputs?(provider)
    # Only OpenAI models with specific versions support structured outputs
    # Models that support json_schema: gpt-4o, gpt-4o-mini, gpt-4-turbo (2024-04-09+)
    return false unless provider.provider == :openai

    model = provider.model.to_s.downcase
    model.include?("gpt-4o") || model.include?("gpt-4-turbo")
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

      Also suggest 2-5 relevant tags/categories for this credential based on its type and content.
      Examples: "Medical License", "Nursing", "CPR Certification", "Board Certification", "DEA License", "BLS", "ACLS", "Specialty Certification"

      Return your response as JSON with this structure:
      {
        "title": "string - Official credential name from the certificate",
        "start_date": "string in YYYY-MM-DD format or null",
        "end_date": "string in YYYY-MM-DD format or null",
        "issuing_organization": "string or null",
        "credential_number": "string or null",
        "document_summary": "string or null",
        "warnings": ["array of warning strings"],
        "suggested_tags": ["array of 2-5 relevant tag strings"]
      }
    PROMPT
  end

  def user_prompt_with_text(credential, extracted_text)
    <<~PROMPT
      Analyze the following professional credential/certificate/license text extracted from a PDF.

      Existing details from the database (may be incomplete):
      - Title: #{credential.title.presence || 'Unknown'}
      - Notes: #{credential.notes.presence || 'None provided'}

      EXTRACTED TEXT FROM CERTIFICATE:
      #{extracted_text}

      Extract the official credential title, issuing organization, credential/license number, and start/end dates.
      Dates must use the YYYY-MM-DD format. If only month/year is present, assume the first day of that month.
      If the data is missing or unclear, return null for that field.

      Provide a concise summary of the certificate if possible and include any warnings (e.g., expired, missing signatures).

      Also suggest 2-5 relevant tags/categories for this credential based on its type and content.
      Examples: "Medical License", "Nursing", "CPR Certification", "Board Certification", "DEA License", "BLS", "ACLS", "Specialty Certification"

      Return your response as JSON with this structure:
      {
        "title": "string - Official credential name from the certificate",
        "start_date": "string in YYYY-MM-DD format or null",
        "end_date": "string in YYYY-MM-DD format or null",
        "issuing_organization": "string or null",
        "credential_number": "string or null",
        "document_summary": "string or null",
        "warnings": ["array of warning strings"],
        "suggested_tags": ["array of 2-5 relevant tag strings"]
      }
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

    # Apply suggested tags
    apply_suggested_tags(credential, data[:suggested_tags])
  end

  def apply_suggested_tags(credential, suggested_tags)
    return if suggested_tags.blank?

    # Normalize tag names and create/find tags
    tags_to_apply = suggested_tags.map do |tag_name|
      normalized_name = tag_name.to_s.strip.downcase
      next if normalized_name.blank?

      # Find or create the tag
      Tag.find_or_create_by!(name: normalized_name) do |tag|
        tag.color = Tag::TAG_COLORS.sample # Assign a random color
        tag.is_default = false
        tag.user_id = credential.user_id
      end
    end.compact

    # Associate tags with credential (avoiding duplicates)
    tags_to_apply.each do |tag|
      credential.tags << tag unless credential.tags.include?(tag)
    end
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

  def pdf_file?(credential)
    credential.file.content_type == "application/pdf"
  end

  def extract_pdf_text(credential)
    credential.file.open do |file|
      reader = PDF::Reader.new(file.path)
      text = reader.pages.map(&:text).join("\n")

      # Clean up the text
      text.gsub(/\s+/, " ").strip
    end
  rescue PDF::Reader::MalformedPDFError => e
    Rails.logger.error "Failed to extract text from PDF for credential ##{credential.id}: #{e.message}"
    raise "Unable to extract text from PDF. The file may be corrupted or image-based."
  rescue => e
    Rails.logger.error "Unexpected error extracting PDF text for credential ##{credential.id}: #{e.message}"
    raise "Error processing PDF file: #{e.message}"
  end
end
