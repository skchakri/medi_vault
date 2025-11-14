# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
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
      :phone,
      :npi,
      :title,
      :official_credentials,
      :mailing_address,
      :practice_address,
      :location_address,
      :npi_data,
      :npi_enumeration_type,
      :npi_verified_at
    ])
  end
end
