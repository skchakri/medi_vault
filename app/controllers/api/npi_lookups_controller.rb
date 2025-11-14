# frozen_string_literal: true

module Api
  class NpiLookupsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:lookup]
    skip_before_action :authenticate_user!, only: [:lookup]

    def lookup
      npi = params[:npi]

      unless npi.present? && npi.match?(/\A\d{10}\z/)
        render json: { success: false, error: "NPI must be exactly 10 digits" }, status: :unprocessable_entity
        return
      end

      # Create a temporary user object to populate
      temp_user = User.new
      result = NpiLookupService.call(user: temp_user, npi: npi)

      if result.success?
        render json: {
          success: true,
          data: {
            first_name: temp_user.first_name,
            last_name: temp_user.last_name,
            middle_name: temp_user.middle_name,
            name_prefix: temp_user.name_prefix,
            name_suffix: temp_user.name_suffix,
            phone: temp_user.phone,
            title: temp_user.title,
            official_credentials: temp_user.official_credentials,
            gender: temp_user.gender,
            npi_enumeration_type: temp_user.npi_enumeration_type,
            npi_status: temp_user.npi_status,
            enumeration_date: temp_user.enumeration_date,
            certification_date: temp_user.certification_date,
            last_updated: temp_user.last_updated,
            sole_proprietor: temp_user.sole_proprietor,
            organizational_subpart: temp_user.organizational_subpart,
            mailing_address: temp_user.mailing_address,
            practice_address: temp_user.practice_address,
            location_address: temp_user.location_address,
            formatted_mailing_address: temp_user.formatted_mailing_address,
            formatted_practice_address: temp_user.formatted_practice_address,
            formatted_location_address: temp_user.formatted_location_address,
            taxonomies: temp_user.taxonomies,
            identifiers: temp_user.identifiers
          }
        }
      else
        render json: { success: false, error: result.errors.join(", ") }, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error("NPI Lookup API Error: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { success: false, error: "An error occurred during NPI lookup" }, status: :internal_server_error
    end
  end
end
