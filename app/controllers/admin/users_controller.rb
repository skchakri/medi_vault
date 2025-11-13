# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    def index
      @users = User.order(created_at: :desc).page(params[:page]).per(50)
    end

    def show
      @user = User.find(params[:id])
      @credentials = @user.credentials.order(created_at: :desc)
      @llm_requests = @user.llm_requests.order(created_at: :desc).limit(20)
    end

    def toggle_admin
      @user = User.find(params[:id])
      new_role = @user.admin? ? :user : :admin

      @user.update!(role: new_role)
      flash[:notice] = "User role updated to #{new_role}"
      redirect_to admin_users_path
    end

    def send_password_reset
      @user = User.find(params[:id])
      @user.send_reset_password_instructions
      flash[:notice] = "Password reset email sent to #{@user.email}"
      redirect_to admin_reports_users_path
    end

    def destroy
      @user = User.find(params[:id])

      if @user == current_user
        flash[:alert] = "You cannot delete your own account"
        redirect_to admin_users_path and return
      end

      @user.destroy
      flash[:notice] = "User deleted successfully"
      redirect_to admin_users_path
    end
  end
end
