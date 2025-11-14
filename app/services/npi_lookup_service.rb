# frozen_string_literal: true

class NpiLookupService < ApplicationService
  def initialize(user:, npi:)
    @user = user
    @npi = npi
  end

  def call
    # Validate NPI format
    unless @npi.to_s.match?(/\A\d{10}\z/)
      return failure(errors: ["NPI must be exactly 10 digits"])
    end

    # Fetch data from NPI Registry
    begin
      npi_data = NpiRegistryClient.lookup_by_number(@npi)
    rescue NpiRegistryClient::Error => e
      return failure(errors: ["NPI Registry API error: #{e.message}"])
    end

    unless npi_data
      return failure(errors: ["NPI #{@npi} not found in registry"])
    end

    # Populate user from NPI data
    populate_user_from_npi_data(npi_data)

    # Store full response
    @user.npi_data = npi_data
    @user.npi = @npi
    @user.npi_verified_at = Time.current
    @user.npi_enumeration_type = npi_data["enumeration_type"]

    success(data: { user: @user, npi_data: npi_data })
  rescue StandardError => e
    Rails.logger.error("NPI Lookup Service Error: #{e.message}\n#{e.backtrace.join("\n")}")
    failure(errors: ["An error occurred during NPI lookup: #{e.message}"])
  end

  private

  def populate_user_from_npi_data(npi_data)
    enumeration_type = npi_data["enumeration_type"]
    basic = npi_data["basic"] || {}

    case enumeration_type
    when "NPI-1"
      # Individual provider - use basic fields
      @user.first_name ||= basic["first_name"]
      @user.last_name ||= basic["last_name"]
      @user.title ||= basic["credential"]
      @user.official_credentials ||= basic["credential"]
    when "NPI-2"
      # Organization - use authorized official fields
      @user.first_name ||= basic["authorized_official_first_name"]
      @user.last_name ||= basic["authorized_official_last_name"]
      @user.phone ||= format_phone(basic["authorized_official_telephone_number"])
      @user.title ||= basic["authorized_official_title_or_position"]
      @user.official_credentials ||= basic["authorized_official_credential"]
    end

    # Extract addresses
    extract_addresses(npi_data["addresses"] || [])
  end

  def extract_addresses(addresses)
    addresses.each do |addr|
      address_data = {
        "address_1" => addr["address_1"],
        "address_2" => addr["address_2"],
        "city" => addr["city"],
        "state" => addr["state"],
        "postal_code" => addr["postal_code"],
        "country_code" => addr["country_code"],
        "telephone_number" => addr["telephone_number"],
        "fax_number" => addr["fax_number"]
      }

      case addr["address_purpose"]
      when "MAILING"
        @user.mailing_address ||= address_data
      when "LOCATION"
        @user.location_address ||= address_data
      when "PRACTICE"
        @user.practice_address ||= address_data
      end
    end

    # If no practice address but have location, use location as practice
    @user.practice_address ||= @user.location_address if @user.location_address
  end

  def format_phone(phone_number)
    return nil if phone_number.blank?

    # Remove all non-digit characters
    digits = phone_number.to_s.gsub(/\D/, '')

    # Format as +1XXXXXXXXXX for US numbers (10 digits)
    if digits.length == 10
      "+1#{digits}"
    else
      phone_number
    end
  end
end
