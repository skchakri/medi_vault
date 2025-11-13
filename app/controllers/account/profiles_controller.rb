# frozen_string_literal: true

module Account
  class ProfilesController < ApplicationController
    def show
      @user = current_user
    end

    def update
      @user = current_user

      if @user.update_without_password(profile_params)
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
  end
end
