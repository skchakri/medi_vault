# frozen_string_literal: true

module Admin
  class ApiSettingsController < AdminController
    def index
      @settings = ApiSetting.all.order(key: :asc)
    end

    def new
      @setting = ApiSetting.new
    end

    def create
      @setting = ApiSetting.new(setting_params)

      if @setting.save
        flash[:notice] = "Setting created successfully"
        redirect_to admin_api_settings_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @setting = ApiSetting.find(params[:id])
    end

    def update
      @setting = ApiSetting.find(params[:id])

      if @setting.update(setting_params)
        flash[:notice] = "Setting updated successfully"
        redirect_to admin_api_settings_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @setting = ApiSetting.find(params[:id])
      @setting.destroy
      flash[:notice] = "Setting deleted successfully"
      redirect_to admin_api_settings_path
    end

    private

    def setting_params
      params.require(:api_setting).permit(:key, :value, :encrypted_value, :description, :enabled)
    end
  end
end
