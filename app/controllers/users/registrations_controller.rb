# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout 'application'

  before_action :configure_sign_up_params, only: [:create]

  # POST /resource
  def create
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :middle_name,
      :name_prefix,
      :name_suffix,
      :phone,
      :npi,
      :title,
      :official_credentials,
      :gender,
      :npi_status,
      :enumeration_date,
      :certification_date,
      :last_updated,
      :sole_proprietor,
      :organizational_subpart,
      :mailing_address,
      :practice_address,
      :location_address,
      :npi_data,
      :npi_enumeration_type,
      :npi_verified_at,
      :taxonomies,
      :identifiers
    ])
  end
end
