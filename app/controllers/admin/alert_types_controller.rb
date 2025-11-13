# frozen_string_literal: true

module Admin
  class AlertTypesController < AdminController
    before_action :set_alert_type, only: [:edit, :update, :destroy]

    def index
      @alert_types = AlertType.ordered
    end

    def new
      @alert_type = AlertType.new
    end

    def create
      @alert_type = AlertType.new(alert_type_params)

      if @alert_type.save
        redirect_to admin_alert_types_path, notice: 'Alert type was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @alert_type.update(alert_type_params)
        redirect_to admin_alert_types_path, notice: 'Alert type was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @alert_type.destroy
      redirect_to admin_alert_types_url, notice: 'Alert type was successfully destroyed.'
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_alert_types_url, alert: 'Cannot delete this alert type as it is in use.'
    end

    private

    def set_alert_type
      @alert_type = AlertType.find(params[:id])
    end

    def alert_type_params
      params.require(:alert_type).permit(
        :name, :offset_days, :description, :active, :priority,
        notification_channels: [], user_plans: []
      )
    end
  end
end
