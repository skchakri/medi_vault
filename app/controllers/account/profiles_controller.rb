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
      result = NpiVerificationService.call(user: current_user, npi: params[:npi])

      if result.success?
        flash[:notice] = "NPI verified successfully!"
        redirect_to account_profile_path
      else
        flash[:alert] = "NPI verification failed: #{result.errors.join(', ')}"
        redirect_to account_profile_path
      end
    end

    private

    def profile_params
      params.require(:user).permit(:first_name, :last_name, :phone, :npi, :notification_email, :notification_sms, :avatar)
    end

    # Check if we need to validate password (if user is trying to change password)
    def needs_password?(user, params)
      params[:password].present? || params[:password_confirmation].present?
    end
  end
end
