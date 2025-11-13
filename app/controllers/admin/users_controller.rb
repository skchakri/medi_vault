# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :edit, :update, :toggle_admin, :send_password_reset, :destroy]

    def index
      @users = User.order(created_at: :desc).page(params[:page]).per(50)
    end

    def show
      @credentials = @user.credentials.order(created_at: :desc)
      @llm_requests = @user.llm_requests.order(created_at: :desc).limit(20)
      @total_tokens = @user.llm_requests.sum(:total_tokens)
    end

    def edit
    end

    def update
      if @user.update_without_password(user_params)
        flash[:notice] = "User profile updated successfully"
        redirect_to admin_user_path(@user)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_admin
      new_role = @user.admin? ? :user : :admin

      @user.update!(role: new_role)
      flash[:notice] = "User role updated to #{new_role}"
      redirect_to admin_users_path
    end

    def send_password_reset
      @user.send_reset_password_instructions
      flash[:notice] = "Password reset email sent to #{@user.email}"
      redirect_to admin_user_path(@user)
    end

    def destroy
      if @user == current_user
        flash[:alert] = "You cannot delete your own account"
        redirect_to admin_users_path and return
      end

      @user.destroy
      flash[:notice] = "User deleted successfully"
      redirect_to admin_users_path
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :npi, :plan, :role, :notification_email, :notification_sms)
    end
  end
end
