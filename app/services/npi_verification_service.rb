# frozen_string_literal: true

class NpiVerificationService < ApplicationService
  NPI_REGISTRY_URL = 'https://npiregistry.cms.hhs.gov/api/'

  def initialize(user:, npi:)
    @user = user
    @npi = npi.to_s.strip
  end

  def call
    return failure('Invalid NPI format') unless valid_npi_format?

    npi_data = fetch_npi_data
    return failure('NPI not found in registry') unless npi_data

    match_result = fuzzy_match_name(npi_data)

    if match_result[:confidence] >= 0.7
      @user.update!(npi: @npi, npi_verified_at: Time.current)
      success(data: { verified: true, confidence: match_result[:confidence], npi_data: npi_data })
    else
      failure("Name doesn't match NPI registry (confidence: #{match_result[:confidence]})")
    end
  rescue => e
    failure("Verification failed: #{e.message}")
  end

  private

  def valid_npi_format?
    @npi.match?(/\A\d{10}\z/)
  end

  def fetch_npi_data
    api_url = ApiSetting.get('npi_api_url') || NPI_REGISTRY_URL

    response = HTTParty.get(
      api_url,
      query: { version: '2.1', number: @npi },
      timeout: 10
    )

    return nil unless response.success?

    data = JSON.parse(response.body)
    return nil if data['result_count'].to_i.zero?

    data['results'].first
  end

  def fuzzy_match_name(npi_data)
    user_name = "#{@user.first_name} #{@user.last_name}".downcase
    npi_first = npi_data.dig('basic', 'first_name')&.downcase || ''
    npi_last = npi_data.dig('basic', 'last_name')&.downcase || ''
    npi_full = "#{npi_first} #{npi_last}"

    # Simple similarity check
    if user_name == npi_full
      return { match: true, confidence: 1.0, reasoning: 'Exact match' }
    end

    # Check if names are substrings of each other
    if user_name.include?(npi_full) || npi_full.include?(user_name)
      return { match: true, confidence: 0.9, reasoning: 'Partial match' }
    end

    # Use LLM for fuzzy matching
    llm_match_name(user_name, npi_full)
  end

  def llm_match_name(user_name, npi_name)
    prompt = <<~PROMPT
      Compare these two names and determine if they likely belong to the same person.

      User provided: #{user_name}
      NPI Registry: #{npi_name}

      Consider:
      - Common nicknames (Bob/Robert, Bill/William, etc.)
      - Middle names or initials
      - Spelling variations
      - Maiden names

      Respond with ONLY a JSON object:
      {
        "match": true/false,
        "confidence": 0.0-1.0,
        "reasoning": "brief explanation"
      }
    PROMPT

    result = LlmService.call(prompt: prompt, user: @user)

    if result.success?
      JSON.parse(result.data[:response]).symbolize_keys
    else
      { match: false, confidence: 0.0, reasoning: 'LLM unavailable' }
    end
  rescue JSON::ParserError
    { match: false, confidence: 0.0, reasoning: 'Parse error' }
  end
end
