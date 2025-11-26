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

    # Handle multiple offset_days (checkboxes)
    offset_days_array = Array(params[:offset_days]).reject(&:blank?)

    if offset_days_array.present?
      created_count = 0
      failed = []

      offset_days_array.each do |offset_days|
        # Skip if alert already exists for this offset
        next if @credential.alerts.exists?(offset_days: offset_days)

        alert_date = @credential.end_date - offset_days.to_i.days
        alert = @credential.alerts.new(
          offset_days: offset_days.to_i,
          alert_date: alert_date,
          message: params[:alert]&.dig(:message).presence || "Your #{@credential.title} expires in #{offset_days} days"
        )

        if alert.save
          created_count += 1
        else
          failed << offset_days
        end
      end

      if created_count > 0 && failed.empty?
        flash[:notice] = "#{created_count} alert#{created_count > 1 ? 's' : ''} created successfully"
      elsif created_count > 0
        flash[:notice] = "#{created_count} alert#{created_count > 1 ? 's' : ''} created. Some alerts may already exist."
      else
        flash[:alert] = "No new alerts created. Alerts may already exist for selected times."
      end
    else
      flash[:alert] = "Please select at least one alert time"
    end

    redirect_to @credential
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
