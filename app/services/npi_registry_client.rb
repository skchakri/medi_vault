# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class NpiRegistryClient
  DEFAULT_BASE_URL = "https://npiregistry.cms.hhs.gov/api/".freeze
  DEFAULT_API_VERSION = "2.1".freeze

  class Error < StandardError; end

  # Lookup a single NPI; returns the first result hash or nil
  def self.lookup_by_number(npi)
    base_url = ApiSetting.get('npi_api_url') || DEFAULT_BASE_URL
    api_version = ApiSetting.get('npi_api_version') || DEFAULT_API_VERSION

    uri = URI(base_url)
    uri.query = URI.encode_www_form(
      version: api_version,
      number: npi.to_s
    )

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.read_timeout = 10
      http.open_timeout = 10
      http.get(uri.request_uri)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise Error, "NPPES HTTP error: #{response.code} #{response.message}"
    end

    body = JSON.parse(response.body)
    return nil if body["result_count"].to_i.zero?

    body["results"].first
  rescue StandardError => e
    Rails.logger.error("NPI Registry API Error: #{e.message}")
    raise Error, "Failed to lookup NPI: #{e.message}"
  end
end
