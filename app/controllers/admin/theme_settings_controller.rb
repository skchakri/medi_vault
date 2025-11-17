# frozen_string_literal: true

module Admin
  class ThemeSettingsController < AdminController
    def edit
      @theme_setting = ThemeSetting.current
    end

    def update
      @theme_setting = ThemeSetting.current

      if @theme_setting.update(theme_setting_params)
        redirect_to edit_admin_theme_settings_path, notice: 'Theme settings updated successfully. Changes will reflect across the application.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def apply_defaults
      @theme_setting = ThemeSetting.current

      # Reset to default values
      @theme_setting.update!(
        primary_color: "#7E22CE",
        secondary_color: "#9333EA",
        font_family: "system"
      )

      # Remove logo if attached
      @theme_setting.logo.purge if @theme_setting.logo.attached?

      redirect_to edit_admin_theme_settings_path, notice: 'Theme settings have been reset to defaults.'
    end

    private

    def theme_setting_params
      params.require(:theme_setting).permit(:primary_color, :secondary_color, :font_family, :logo)
    end
  end
end
