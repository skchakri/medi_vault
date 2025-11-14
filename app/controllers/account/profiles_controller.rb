# frozen_string_literal: true

module Account
  class ProfilesController < ApplicationController
    def show
      @user = current_user
    end

    def update
      @user = current_user

      # Use update_without_password for Devise to skip password validation
      successfully_updated = if needs_password?(@user, profile_params)
        @user.update(profile_params)
      else
        @user.update_without_password(profile_params)
      end

      if successfully_updated
        flash[:notice] = "Profile updated successfully"
        redirect_to account_profile_path
      else
        render :show, status: :unprocessable_entity
      end
    end

    def verify_npi
      result = NpiLookupService.call(user: current_user, npi: params[:npi])

      if result.success?
        # Save the populated data
        if current_user.save
          flash[:notice] = "NPI verified successfully! Your profile has been updated with information from the NPI Registry."
          redirect_to account_profile_path
        else
          flash[:alert] = "NPI verified but failed to save: #{current_user.errors.full_messages.join(', ')}"
          redirect_to account_profile_path
        end
      else
        flash[:alert] = "NPI verification failed: #{result.errors.join(', ')}"
        redirect_to account_profile_path
      end
    end

    private

    def profile_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :phone,
        :npi,
        :title,
        :official_credentials,
        :notification_email,
        :notification_sms,
        :avatar,
        mailing_address: {},
        practice_address: {},
        location_address: {}
      )
    end

    # Check if we need to validate password (if user is trying to change password)
    def needs_password?(user, params)
      params[:password].present? || params[:password_confirmation].present?
    end
  end
end
