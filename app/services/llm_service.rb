# frozen_string_literal: true

class LlmService < ApplicationService
  def initialize(prompt:, user: nil, provider: nil, model: nil)
    @prompt = prompt
    @user = user
    @provider = provider || default_provider
    @model = model || default_model
  end

  def call
    start_time = Time.current
    llm_request = create_llm_request

    response = make_llm_call
    duration = Time.current - start_time

    llm_request.update!(
      success: true,
      total_tokens: response[:tokens],
      cost_cents: response[:cost_cents]
    )

    success(data: { response: response[:content], llm_request: llm_request })
  rescue => e
    llm_request&.update!(success: false, error_text: e.message)
    failure(e.message)
  end

  private

  def create_llm_request
    LlmRequest.create!(
      user: @user,
      provider: @provider,
      model: @model,
      request_type: 'general'
    )
  end

  def default_provider
    if ApiSetting.get('ollama_url').present?
      :ollama
    elsif ApiSetting.get('openai_api_key').present?
      :openai
    else
      raise 'No LLM provider configured'
    end
  end

  def default_model
    case @provider
    when :openai
      ApiSetting.get('openai_model') || 'gpt-4o-mini'
    when :ollama
      ApiSetting.get('ollama_model') || 'llama3.2'
    end
  end

  def make_llm_call
    case @provider
    when :openai
      call_openai
    when :ollama
      call_ollama
    else
      raise "Unknown provider: #{@provider}"
    end
  end

  def call_openai
    api_key = ApiSetting.get('openai_api_key')
    raise 'OpenAI API key not configured' unless api_key

    client = OpenAI::Client.new(access_token: api_key)
    response = client.chat(
      parameters: {
        model: @model,
        messages: [{ role: 'user', content: @prompt }],
        temperature: 0.1
      }
    )

    content = response.dig('choices', 0, 'message', 'content')
    tokens = response.dig('usage', 'total_tokens') || 0
    cost_cents = calculate_openai_cost(tokens, @model)

    { content: content, tokens: tokens, cost_cents: cost_cents }
  end

  def call_ollama
    url = ApiSetting.get('ollama_url') || 'http://localhost:11434'
    response = HTTParty.post(
      "#{url}/api/generate",
      body: {
        model: @model,
        prompt: @prompt,
        stream: false
      }.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: 120
    )

    { content: response.parsed_response['response'], tokens: 0, cost_cents: 0 }
  end

  def calculate_openai_cost(tokens, model)
    # Rough cost estimates in cents
    rate_per_1k = case model
                  when /gpt-4o-mini/ then 0.015
                  when /gpt-4o/ then 0.25
                  when /gpt-4/ then 3.0
                  when /gpt-3.5/ then 0.1
                  else 0.01
                  end

    ((tokens / 1000.0) * rate_per_1k * 100).to_i
  end
end
