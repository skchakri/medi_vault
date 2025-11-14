# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :lookup_npi, only: [:create]

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
      :location_address
    ])
  end

  # Lookup NPI and populate user fields before creating the account
  def lookup_npi
    return unless params[:user][:npi].present?

    # Build user object to populate
    @npi_user = User.new

    # Call NPI lookup service
    result = NpiLookupService.call(user: @npi_user, npi: params[:user][:npi])

    if result.success?
      # Populate form params with NPI data (only if not already provided)
      params[:user][:first_name] ||= @npi_user.first_name
      params[:user][:last_name] ||= @npi_user.last_name
      params[:user][:phone] ||= @npi_user.phone
      params[:user][:title] ||= @npi_user.title
      params[:user][:official_credentials] ||= @npi_user.official_credentials
      params[:user][:mailing_address] ||= @npi_user.mailing_address
      params[:user][:practice_address] ||= @npi_user.practice_address
      params[:user][:location_address] ||= @npi_user.location_address

      # Store NPI data and verification info
      params[:user][:npi_data] = @npi_user.npi_data
      params[:user][:npi_enumeration_type] = @npi_user.npi_enumeration_type
      params[:user][:npi_verified_at] = @npi_user.npi_verified_at

      flash.now[:notice] = "NPI verified! Your information has been auto-filled from the NPI Registry."
    else
      # Log error but allow registration to continue
      Rails.logger.warn("NPI lookup failed during registration: #{result.errors.join(', ')}")
      flash.now[:alert] = "Could not verify NPI automatically. You can verify it later in your profile."
    end
  rescue StandardError => e
    # Log error but don't block registration
    Rails.logger.error("NPI lookup error during registration: #{e.message}")
    flash.now[:alert] = "NPI verification temporarily unavailable. You can verify it later in your profile."
  end
end
