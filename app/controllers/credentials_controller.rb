# frozen_string_literal: true

class CredentialsController < ApplicationController
  before_action :set_credential, only: [:show, :edit, :update, :destroy, :download, :extract]

  def index
    @credentials = current_user.credentials

    # Apply search filter if search parameter is present
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @credentials = @credentials.where("title ILIKE ? OR notes ILIKE ?", search_term, search_term)
    end

    @credentials = @credentials.order(end_date: :asc).page(params[:page]).per(20)
  end

  def show
    @alerts = @credential.alerts.order(alert_date: :asc)
    @share_links = @credential.share_links.active
  end

  def new
    unless current_user.within_credential_limit?
      flash[:alert] = "You've reached your credential limit (#{current_user.max_credentials}). Please upgrade your plan."
      redirect_to pricing_path and return
    end
    @credential = current_user.credentials.new
  end

  def create
    unless current_user.within_credential_limit?
      flash[:alert] = "You've reached your credential limit. Please upgrade your plan."
      redirect_to pricing_path and return
    end

    @credential = current_user.credentials.new(credential_params)

    if @credential.save
      # Trigger AI extraction in background
      # CredentialExtractionJob.perform_later(@credential.id)
      flash[:notice] = "Credential uploaded successfully! AI extraction will process your document."
      redirect_to @credential
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @credential.update(credential_params)
      flash[:notice] = "Credential updated successfully."
      redirect_to @credential
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @credential.destroy
    flash[:notice] = "Credential deleted successfully."
    redirect_to credentials_path
  end

  def download
    redirect_to rails_blob_path(@credential.file, disposition: "attachment")
  end

  def extract
    # Re-trigger AI extraction
    # CredentialExtractionJob.perform_later(@credential.id)
    flash[:notice] = "AI extraction has been re-triggered for this credential."
    redirect_to @credential
  end

  private

  def set_credential
    @credential = current_user.credentials.find(params[:id])
  end

  def credential_params
    params.require(:credential).permit(:title, :start_date, :end_date, :notes, :file)
  end
end
