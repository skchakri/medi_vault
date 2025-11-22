# frozen_string_literal: true

module AiTools
  ToolSpec = Struct.new(:name, :description, :inputs, :outputs)

  REGISTRY = {
    file_inspector: ToolSpec.new(
      'File Inspector',
      'Detects mime/type/extension and basic file metadata.',
      ['file_blob_id|path'],
      %w[mime_type extension size_bytes checksum]
    ),
    pdf_reader: ToolSpec.new(
      'PDF Reader',
      'Extracts text and metadata from PDF files.',
      ['file_blob_id|path', 'pages?'],
      ['text', 'pages[]', 'metadata']
    ),
    image_ocr: ToolSpec.new(
      'Image-to-Text OCR',
      'Reads text from document images.',
      ['file_blob_id|path', 'language?', 'dpi_hint?'],
      ['text', 'confidence', 'blocks']
    ),
    embedding_creator: ToolSpec.new(
      'Embedding Creator',
      'Creates embeddings and stores vectors with metadata.',
      ['text', 'source_ref', 'chunk_id?', 'metadata?'],
      ['embedding_id', 'vector_dim', 'provider', 'model', 'cost_cents']
    ),
    field_qa: ToolSpec.new(
      'Field Q&A',
      'Answers a list of prompts over a context text.',
      ['context_text', 'fields[]'],
      ['answers{}', 'confidences']
    ),
    class_method_invoker: ToolSpec.new(
      'Class Method Invoker',
      'Maps hash params to whitelisted class/method invocation.',
      ['class_name', 'method_name', 'args_hash'],
      ['return_value']
    ),
    http_caller: ToolSpec.new(
      'HTTP Caller',
      'Sends GET/POST/DELETE with params and headers.',
      ['url', 'http_method', 'params', 'headers?'],
      ['status', 'body', 'headers']
    ),
    document_classifier: ToolSpec.new(
      'Document Classifier',
      'Auto-tags documents by type (license, certificate, insurance card, etc.).',
      ['text|file_blob_id'],
      ['labels[]', 'top_label']
    ),
    entity_extractor: ToolSpec.new(
      'Entity Extractor',
      'Extracts names, dates, organizations, IDs, addresses as structured JSON.',
      ['text', 'schema_hint?'],
      ['entities']
    ),
    validator_normalizer: ToolSpec.new(
      'Validator/Normalizer',
      'Normalizes fields (dates to ISO, phones to E.164, addresses cleaned).',
      ['raw_fields'],
      ['normalized_fields', 'warnings', 'errors']
    ),
    similarity_search: ToolSpec.new(
      'Similarity Search',
      'Finds related passages/documents using stored embeddings.',
      ['query_text', 'top_k?', 'filters?'],
      ['results[]']
    ),
    speech_to_text: ToolSpec.new(
      'Speech-to-Text',
      'Transcribes audio recordings.',
      ['file_blob_id|path', 'language?', 'model?'],
      ['text', 'confidence', 'segments']
    ),
    form_autofill: ToolSpec.new(
      'Form Autofill',
      'Populates a template and returns a filled PDF.',
      ['template_id|file_blob_id', 'field_values'],
      ['filled_pdf_blob_id', 'summary']
    ),
    webhook_dispatcher: ToolSpec.new(
      'Webhook/Action Dispatcher',
      'Triggers external actions (email, alert, ticket, webhook).',
      ['action_type', 'payload', 'target'],
      ['status', 'reference', 'response']
    )
  }.freeze
end
