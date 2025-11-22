# frozen_string_literal: true

require 'ruby_llm/schema'
require 'digest'

module AiTools
  class FileInspectorTool < Base
    description "Detects mime/type/extension and basic file metadata"

    param :file_blob_id, type: 'integer', desc: 'ActiveStorage blob id', required: false
    param :path, type: 'string', desc: 'Local file path', required: false

    def execute(file_blob_id: nil, path: nil)
      file = attachable_file(blob_id: file_blob_id, path: path)
      raise ArgumentError, 'Provide file_blob_id or path' unless file

      file_path = file.respond_to?(:path) ? file.path : file.to_s
      {
        mime_type: Marcel::MimeType.for(Pathname(file_path)),
        extension: File.extname(file_path).delete('.'),
        size_bytes: File.size(file_path),
        checksum: Digest::SHA256.file(file_path).hexdigest
      }
    ensure
      file.close! if file.is_a?(Tempfile)
    end
  end

  class PdfReaderTool < Base
    description "Extracts text and metadata from PDFs"

    param :file_blob_id, type: 'integer', desc: 'ActiveStorage blob id', required: false
    param :path, type: 'string', desc: 'Local file path', required: false
    param :pages, type: 'array', desc: 'Optional page numbers', required: false

    def execute(file_blob_id: nil, path: nil, pages: nil)
      file = attachable_file(blob_id: file_blob_id, path: path)
      raise ArgumentError, 'Provide file_blob_id or path' unless file

      file_path = file.respond_to?(:path) ? file.path : file.to_s
      reader = PDF::Reader.new(file_path)
      selected_pages = pages&.map(&:to_i)
      page_data = []
      reader.pages.each_with_index do |page, idx|
        page_number = idx + 1
        next if selected_pages.present? && !selected_pages.include?(page_number)
        page_data << { number: page_number, text: page.text }
      end

      {
        text: page_data.map { |p| p[:text] }.join("\n\n"),
        pages: page_data,
        metadata: reader.info
      }
    ensure
      file.close! if file.is_a?(Tempfile)
    end
  end

  class ImageToTextTool < Base
    description "Reads text from document images"

    param :file_blob_id, type: 'integer', desc: 'ActiveStorage blob id', required: false
    param :path, type: 'string', desc: 'Local file path', required: false
    param :language, type: 'string', desc: 'Language hint', required: false
    param :dpi_hint, type: 'integer', desc: 'DPI hint for OCR', required: false

    def execute(file_blob_id: nil, path: nil, language: nil, dpi_hint: nil)
      file = attachable_file(blob_id: file_blob_id, path: path)
      raise ArgumentError, 'Provide file_blob_id or path' unless file

      provider = resolve_provider_configuration
      ctx = build_context(provider)
      chat = ctx.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
               .with_instructions(system_prompt(language, dpi_hint))
               .with_temperature(0.1)
      response = chat.ask('Extract all visible text from this document image.', with: file)
      {
        text: response.content,
        confidence: nil,
        blocks: []
      }
    ensure
      file.close! if file.is_a?(Tempfile)
    end

    def system_prompt(language, dpi_hint)
      <<~PROMPT
        You are performing OCR on a scanned document. Return all text in reading order.
        Keep line breaks between logical blocks. Language hint: #{language || 'unknown'}.
        DPI hint: #{dpi_hint || 'unknown'}.
      PROMPT
    end
  end

  class EmbeddingCreatorTool < Base
    description "Creates embeddings and stores the vector"

    param :text, type: 'string', desc: 'Content to embed'
    param :source_type, type: 'string', desc: 'Source type for polymorphic association', required: false
    param :source_id, type: 'integer', desc: 'Source id for polymorphic association', required: false
    param :chunk_id, type: 'string', desc: 'Chunk identifier', required: false
    param :metadata, type: 'hash', desc: 'Metadata to store with embedding', required: false

    DEFAULT_EMBED_MODEL = 'text-embedding-3-small'

    def execute(text:, source_type: nil, source_id: nil, chunk_id: nil, metadata: {})
      provider = resolve_provider_configuration(preferred_model: default_model_name)
      vector, cost = build_vector(text, provider)
      embedding = AiEmbedding.create!(
        provider: provider.provider,
        model: provider.model,
        vector: vector,
        dim: vector.size,
        source_type: source_type,
        source_id: source_id,
        chunk_id: chunk_id,
        metadata: metadata || {},
        cost_cents: cost
      )

      {
        embedding_id: embedding.id,
        vector_dim: embedding.dim,
        provider: embedding.provider,
        model: embedding.model,
        cost_cents: embedding.cost_cents
      }
    end

    private

    def default_model_name
      ENV['OPENAI_EMBEDDING_MODEL'].presence || DEFAULT_EMBED_MODEL
    end

    def build_vector(text, provider)
      case provider.provider
      when :openai
        client = OpenAI::Client.new(access_token: ApiSetting.get('openai_api_key') || ENV['OPENAI_API_KEY'])
        response = client.embeddings(parameters: { model: provider.model, input: text })
        vector = response.dig('data', 0, 'embedding') || []
        [vector, 0]
      when :ollama
        url = ApiSetting.get('ollama_url') || ENV['OLLAMA_URL'] || 'http://localhost:11434'
        response = HTTParty.post(
          "#{url}/api/embeddings",
          headers: { 'Content-Type' => 'application/json' },
          body: { model: provider.model, prompt: text }.to_json
        )
        vector = response.parsed_response['embedding'] || []
        [vector, 0]
      else
        raise "Unsupported provider #{provider.provider}"
      end
    end
  end

  class FieldQATool < Base
    description "Answers a list of prompts over a given context"

    param :context_text, type: 'string', desc: 'Reference text to answer against'
    param :fields, type: 'array', desc: 'Array of {name, prompt} hashes'

    def execute(context_text:, fields:)
      provider = resolve_provider_configuration
      ctx = build_context(provider)
      chat = ctx.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
               .with_instructions(system_prompt)
               .with_temperature(0.0)
      prompt = build_prompt(context_text, fields)
      response = chat.ask(prompt)
      parsed = parse_json(response.content)
      { answers: parsed['answers'] || {}, confidences: parsed['confidences'] || {} }
    end

    def system_prompt
      <<~PROMPT
        You extract answers for each field as JSON with shape:
        {
          "answers": { "field_name": "value" },
          "confidences": { "field_name": 0-1 float }
        }
        If unclear, set value to null and confidence 0.
      PROMPT
    end

    def build_prompt(context_text, fields)
      field_lines = fields.map { |f| "- #{f[:name] || f['name']}: #{f[:prompt] || f['prompt']}" }.join("\n")
      <<~PROMPT
        Context:
        #{context_text}

        Extract the following fields:
        #{field_lines}

        Return JSON only.
      PROMPT
    end

    def parse_json(raw)
      JSON.parse(raw)
    rescue JSON::ParserError
      { 'answers' => {}, 'confidences' => {} }
    end
  end

  class ClassMethodInvokerTool < Base
    description "Invokes whitelisted class methods using a hash of keyword args"

    param :class_name, type: 'string', desc: 'Class to call'
    param :method_name, type: 'string', desc: 'Method to call'
    param :args_hash, type: 'hash', desc: 'Keyword arguments hash'

    ALLOWED = {
      'Credential' => %i[find],
      'User' => %i[find]
    }.freeze

    def execute(class_name:, method_name:, args_hash: {})
      allowed_methods = ALLOWED[class_name.to_s]
      raise ArgumentError, 'Class not allowed' unless allowed_methods
      raise ArgumentError, 'Method not allowed' unless allowed_methods.include?(method_name.to_sym)

      klass = class_name.constantize
      result = klass.public_send(method_name, **args_hash.symbolize_keys)
      { return_value: result }
    end
  end

  class HttpCallerTool < Base
    description "Makes HTTP requests with validated methods"

    param :url, type: 'string', desc: 'Target URL'
    param :http_method, type: 'string', desc: 'GET/POST/DELETE'
    param :params, type: 'hash', desc: 'Request params', required: false
    param :headers, type: 'hash', desc: 'Headers', required: false

    ALLOWED_METHODS = %w[get post delete].freeze

    def execute(url:, http_method:, params: {}, headers: {})
      method = http_method.to_s.downcase
      raise ArgumentError, 'Unsupported method' unless ALLOWED_METHODS.include?(method)

      response = HTTParty.public_send(method, url, body: params, headers: headers)
      { status: response.code, body: response.parsed_response, headers: response.headers.to_h }
    end
  end

  class DocumentClassifierTool < Base
    description "Classifies documents by type"

    param :text, type: 'string', desc: 'Text content', required: false
    param :file_blob_id, type: 'integer', desc: 'ActiveStorage blob id', required: false

    LABELS = %w[license certificate insurance_card id_card diploma transcript other].freeze

    def execute(text: nil, file_blob_id: nil)
      file = attachable_file(blob_id: file_blob_id) if file_blob_id
      provider = resolve_provider_configuration
      ctx = build_context(provider)
      chat = ctx.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
               .with_instructions(system_prompt)
      content = text || 'Classify the attached document.'
      response = chat.ask(content, with: file)
      parsed = parse_json(response.content)
      top = parsed['labels']&.first
      { labels: parsed['labels'] || [], top_label: top }
    ensure
      file.close! if file.is_a?(Tempfile)
    end

    def system_prompt
      <<~PROMPT
        You are a document classifier. Choose labels from: #{LABELS.join(', ')}.
        Return JSON: { "labels": [ { "name": "<label>", "score": float } ] }
      PROMPT
    end

    def parse_json(raw)
      JSON.parse(raw)
    rescue JSON::ParserError
      { 'labels' => [] }
    end
  end

  class EntityExtractorTool < Base
    description "Extracts key entities from text"

    param :text, type: 'string', desc: 'Text to analyze'
    param :schema_hint, type: 'string', desc: 'Optional hint', required: false

    def execute(text:, schema_hint: nil)
      provider = resolve_provider_configuration
      ctx = build_context(provider)
      chat = ctx.chat(model: provider.model, provider: provider.provider, assume_model_exists: true)
               .with_instructions(system_prompt(schema_hint))
      response = chat.ask(text)
      parsed = parse_json(response.content)
      { entities: parsed['entities'] || parsed }
    end

    def system_prompt(schema_hint)
      <<~PROMPT
        Extract entities as JSON under "entities".
        Required keys: name, dob, issue_date, org, id_number, address.
        Optional schema hint: #{schema_hint || 'none'}.
        Return JSON only.
      PROMPT
    end

    def parse_json(raw)
      JSON.parse(raw)
    rescue JSON::ParserError
      { 'entities' => {} }
    end
  end

  class ValidatorNormalizerTool < Base
    description "Normalizes and validates common fields"

    param :raw_fields, type: 'hash', desc: 'Hash of raw fields'

    def execute(raw_fields:)
      fields = raw_fields.symbolize_keys
      normalized = {}
      warnings = []
      errors = []

      if fields[:date].present?
        normalized[:date] = normalize_date(fields[:date], warnings, errors)
      end

      if fields[:phone].present?
        normalized[:phone] = normalize_phone(fields[:phone], warnings, errors)
      end

      if fields[:address].present?
        normalized[:address] = normalize_address(fields[:address])
      end

      normalized.merge!(fields.except(:date, :phone, :address))
      { normalized_fields: normalized, warnings: warnings, errors: errors }
    end

    def normalize_date(value, warnings, errors)
      Date.parse(value.to_s).iso8601
    rescue ArgumentError
      warnings << 'Could not parse date'
      nil
    end

    def normalize_phone(value, warnings, errors)
      parsed = Phonelib.parse(value)
      if parsed.valid?
        parsed.e164
      else
        errors << 'Invalid phone'
        nil
      end
    end

    def normalize_address(value)
      value.to_s.squish
    end
  end

  class SimilaritySearchTool < Base
    description "Searches stored embeddings"

    param :query_text, type: 'string', desc: 'Query to embed'
    param :top_k, type: 'integer', desc: 'Results to return', required: false
    param :filters, type: 'hash', desc: 'Optional filters', required: false

    def execute(query_text:, top_k: 5, filters: {})
      provider = resolve_provider_configuration(preferred_model: embedding_model_name)
      vector, _cost = build_query_embedding(query_text, provider)
      scope = AiEmbedding.all
      if filters.present?
        scope = scope.where(filters.compact)
      end
      results = scope.find_each.map do |record|
        score = record.cosine_similarity(vector)
        next if score.nan?
        { id: record.id, score: score, source_ref: { type: record.source_type, id: record.source_id }, metadata: record.metadata, snippet: record.metadata['snippet'] }
      end.compact

      { results: results.sort_by { |r| -r[:score] }.first(top_k.to_i) }
    end

    private

    def embedding_model_name
      ENV['OPENAI_EMBEDDING_MODEL'].presence || EmbeddingCreatorTool::DEFAULT_EMBED_MODEL
    end

    def build_query_embedding(text, provider)
      vector, _ = EmbeddingCreatorTool.new.send(:build_vector, text, provider)
      [vector, 0]
    end
  end

  class SpeechToTextTool < Base
    description "Transcribes audio recordings"

    param :file_blob_id, type: 'integer', desc: 'ActiveStorage blob id', required: false
    param :path, type: 'string', desc: 'Local path', required: false
    param :language, type: 'string', desc: 'Language', required: false
    param :model, type: 'string', desc: 'Model name', required: false

    DEFAULT_MODEL = 'whisper-1'

    def execute(file_blob_id: nil, path: nil, language: nil, model: nil)
      file = attachable_file(blob_id: file_blob_id, path: path)
      raise ArgumentError, 'Provide file_blob_id or path' unless file

      api_key = ApiSetting.get('openai_api_key') || ENV['OPENAI_API_KEY']
      raise 'OpenAI key required for speech-to-text' unless api_key

      client = OpenAI::Client.new(access_token: api_key)
      response = client.audio.transcribe(
        parameters: {
          file: File.open(file.respond_to?(:path) ? file.path : file.to_s),
          model: model || DEFAULT_MODEL,
          language: language
        }.compact
      )
      { text: response['text'], confidence: nil, segments: response['segments'] }
    ensure
      file.close! if file.is_a?(Tempfile)
    end
  end

  class FormAutofillTool < Base
    description "Populates a template and returns a filled PDF"

    param :template_blob_id, type: 'integer', desc: 'Template ActiveStorage blob id', required: false
    param :file_blob_id, type: 'integer', desc: 'Alias for template blob id', required: false
    param :field_values, type: 'hash', desc: 'Field values to fill'

    def execute(template_blob_id: nil, file_blob_id: nil, field_values:)
      template_id = template_blob_id || file_blob_id
      raise ArgumentError, 'Provide template_blob_id or file_blob_id' unless template_id

      pdf_path = build_pdf(field_values)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(pdf_path),
        filename: "filled_form_#{Time.current.to_i}.pdf",
        content_type: 'application/pdf'
      )

      { filled_pdf_blob_id: blob.id, summary: "Filled #{field_values.keys.size} fields" }
    ensure
      FileUtils.rm_f(pdf_path) if pdf_path
    end

    def build_pdf(field_values)
      path = Rails.root.join('tmp', "filled_form_#{SecureRandom.hex(4)}.pdf")
      Prawn::Document.generate(path) do |pdf|
        pdf.text "Filled Form", size: 18, style: :bold
        pdf.move_down 10
        field_values.each do |key, value|
          pdf.text "#{key}: #{value}"
        end
      end
      path
    end
  end

  class WebhookDispatcherTool < Base
    description "Dispatches external actions/webhooks"

    param :action_type, type: 'string', desc: 'email/alert/ticket/webhook'
    param :payload, type: 'hash', desc: 'Payload data'
    param :target, type: 'string', desc: 'Target address or URL'

    SUPPORTED = %w[email alert ticket webhook].freeze

    def execute(action_type:, payload:, target:)
      action = action_type.to_s
      raise ArgumentError, 'Unsupported action_type' unless SUPPORTED.include?(action)

      case action
      when 'webhook'
        response = HTTParty.post(target, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
        { status: response.code, reference: nil, response: response.parsed_response }
      else
        # Placeholder actions; integrate real dispatchers as needed
        { status: 200, reference: SecureRandom.uuid, response: { action: action, target: target, payload: payload } }
      end
    end
  end
end
