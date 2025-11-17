# frozen_string_literal: true

class AlertsController < ApplicationController
  before_action :set_credential, only: [:create]
  before_action :set_alert, only: [:destroy]

  def index
    @alerts = current_user.alerts
                         .includes(:credential)
                         .order(alert_date: :asc)
                         .page(params[:page])
                         .per(20)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @credential = current_user.credentials.find(params[:credential_id])

    unless current_user.within_alert_limit?(@credential)
      flash[:alert] = "Maximum alerts reached for this credential on your #{current_user.plan} plan"
      redirect_to @credential and return
    end

    @alert = @credential.alerts.new(alert_params)

    if @alert.save
      flash[:notice] = "Alert created successfully"
      redirect_to @credential
    else
      flash[:alert] = @alert.errors.full_messages.join(", ")
      redirect_to @credential
    end
  end

  def destroy
    credential = @alert.credential
    @alert.destroy
    flash[:notice] = "Alert deleted successfully"
    redirect_to credential
  end

  private

  def set_credential
    @credential = current_user.credentials.find(params[:credential_id])
  end

  def set_alert
    @alert = current_user.alerts.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:offset_days, :message)
  end
end
