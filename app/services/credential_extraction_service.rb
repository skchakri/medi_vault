# frozen_string_literal: true

class CredentialExtractionService < ApplicationService
  def initialize(credential:)
    @credential = credential
  end

  def call
    return failure('No file attached') unless @credential.file.attached?

    text = extract_text_from_file
    return failure('Could not extract text') if text.blank?

    extracted_data = extract_with_llm(text)
    return failure('LLM extraction failed') unless extracted_data

    update_credential(extracted_data)
    success(data: extracted_data)
  rescue => e
    failure("Extraction failed: #{e.message}")
  end

  private

  def extract_text_from_file
    case @credential.file.content_type
    when 'application/pdf'
      extract_from_pdf
    when /^image\//
      extract_from_image
    else
      nil
    end
  end

  def extract_from_pdf
    return nil unless @credential.file.blob.present?

    # Try OpenAI Vision API first (handles scanned PDFs better)
    extracted_with_vision = extract_pdf_with_vision
    return extracted_with_vision if extracted_with_vision.present?

    # Fall back to PDF::Reader for text-based PDFs
    extract_pdf_with_reader
  rescue => e
    Rails.logger.error "PDF extraction error: #{e.message}"
    nil
  end

  def extract_pdf_with_vision
    return nil unless @credential.file.blob.present?

    # Download the PDF and convert to base64
    pdf_data = @credential.file.download
    base64_pdf = Base64.strict_encode64(pdf_data)

    # Get the API key
    api_key = ApiSetting.get("openai_api_key")
    return nil unless api_key

    client = OpenAI::Client.new(access_token: api_key)

    # Use image_url format with PDF media type (OpenAI now supports PDFs this way)
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Extract all text content from this professional credential/certificate/license PDF document. Return the complete text exactly as it appears, preserving the document structure and layout."
              },
              {
                type: "image_url",
                image_url: {
                  url: "data:application/pdf;base64,#{base64_pdf}"
                }
              }
            ]
          }
        ],
        max_tokens: 4000
      }
    )

    # Extract the text content from the response
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.warn "PDF Vision extraction failed, will fall back to PDF::Reader: #{e.message}"
    nil
  end

  def extract_pdf_with_reader
    return nil unless @credential.file.blob.present?

    # Download the file temporarily
    tempfile = @credential.file.download
    reader = PDF::Reader.new(tempfile)
    reader.pages.map(&:text).join("\n")
  rescue => e
    Rails.logger.error "PDF::Reader extraction error: #{e.message}"
    nil
  end

  def extract_from_image
    return nil unless @credential.file.blob.present?

    # Download the image and convert to base64
    image_data = @credential.file.download
    base64_image = Base64.strict_encode64(image_data)

    # Get the image media type
    media_type = @credential.file.content_type || "image/jpeg"

    # Call OpenAI Vision API
    api_key = ApiSetting.get("openai_api_key")
    return nil unless api_key

    client = OpenAI::Client.new(access_token: api_key)

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Extract all text content from this credential/certificate/license image. Return the complete text exactly as it appears."
              },
              {
                type: "image_url",
                image_url: {
                  url: "data:#{media_type};base64,#{base64_image}"
                }
              }
            ]
          }
        ],
        max_tokens: 2000
      }
    )

    # Extract the text content from the response
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "Image extraction error: #{e.message}"
    nil
  end

  def extract_with_llm(text)
    prompt = <<~PROMPT
      You are an expert at analyzing professional credentials, certificates, and licenses.

      Analyze the following document text and extract structured information:

      Document text:
      #{text.truncate(4000)}

      Extract and return ONLY a valid JSON object with these fields:
      {
        "title": "Full name/title of the credential (e.g., 'Medical License', 'CPA Certificate')",
        "start_date": "Start/issue date in YYYY-MM-DD format, or null if not found",
        "end_date": "Expiration/renewal date in YYYY-MM-DD format, or null if not found",
        "issuing_organization": "Name of the organization/body that issued this credential, or null",
        "credential_number": "License/credential/certificate number, or null"
      }

      Rules:
      - Parse dates intelligently (e.g., 'Jan 15, 2023' → '2023-01-15')
      - For dates with only month/year, use the first day of the month
      - If year is missing but context suggests current/recent, make reasonable assumption
      - Credential number can be any ID, license number, certificate number, etc.
      - If any field is not found or unclear, use null
      - Do NOT include any explanation, only the JSON object
      - Ensure the response is valid JSON that can be parsed
    PROMPT

    result = LlmService.call(prompt: prompt, user: @credential.user)

    if result.success?
      response_text = result.data[:response]
      # Extract JSON from response (handling markdown code blocks)
      json_text = response_text[/\{.*\}/m]
      parsed = JSON.parse(json_text).symbolize_keys

      # Validate and clean the parsed data
      {
        title: parsed[:title].presence,
        start_date: parsed[:start_date],
        end_date: parsed[:end_date],
        issuing_organization: parsed[:issuing_organization].presence,
        credential_number: parsed[:credential_number].presence
      }
    else
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    nil
  end

  def update_credential(data)
    @credential.update!(
      title: data[:title].presence || @credential.title,
      start_date: parse_date(data[:start_date]),
      end_date: parse_date(data[:end_date]),
      ai_extracted_json: data,
      ai_processed: true,
      ai_processed_at: Time.current
    )
  end

  def parse_date(date_string)
    return nil if date_string.nil? || date_string == 'null'
    Date.parse(date_string.to_s)
  rescue ArgumentError
    nil
  end
end
