# frozen_string_literal: true

class CredentialsController < ApplicationController
  before_action :set_credential, only: [:show, :edit, :update, :destroy, :download, :extract]

  def index
    @credentials = current_user.credentials

    # Load all available tags for filtering
    @available_tags = Tag.default_tags.or(Tag.user_tags(current_user)).alphabetical

    # Apply tag filter if tag_ids parameter is present
    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].reject(&:blank?)
      if tag_ids.any?
        tag_names = Tag.where(id: tag_ids).pluck(:name)
        @credentials = @credentials.tagged_with_any(tag_names)
      end
    end

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
    load_available_tags
  end

  def create
    unless current_user.within_credential_limit?
      flash[:alert] = "You've reached your credential limit. Please upgrade your plan."
      redirect_to pricing_path and return
    end

    @credential = current_user.credentials.new(credential_params)

    if @credential.save
      flash[:notice] = "Credential uploaded successfully! AI analysis will process your document."
      redirect_to @credential
    else
      load_available_tags
      render :new, status: :unprocessable_entity
    end
  end

  def bulk_new
    unless current_user.within_credential_limit?
      flash[:alert] = "You've reached your credential limit (#{current_user.max_credentials}). Please upgrade your plan."
      redirect_to pricing_path and return
    end
  end

  def bulk_create
    files = params[:files] || []

    if files.empty?
      flash[:alert] = "Please select at least one file to upload."
      redirect_to bulk_new_credentials_path and return
    end

    # Check plan limits
    current_count = current_user.credentials.count
    max_allowed = current_user.max_credentials
    files_count = files.size

    if current_count + files_count > max_allowed
      available_slots = max_allowed - current_count
      flash[:alert] = "You can only upload #{available_slots} more credential(s). Your plan allows #{max_allowed} total credentials. Please upgrade to upload more."
      redirect_to bulk_new_credentials_path and return
    end

    @successes = []
    @failures = []

    files.each do |file|
      credential = current_user.credentials.new(
        title: file.original_filename.gsub(/\.[^.]+\z/, ''), # Remove file extension
        file: file
      )

      if credential.save
        @successes << { credential: credential, filename: file.original_filename }
      else
        @failures << { filename: file.original_filename, errors: credential.errors.full_messages }
      end
    end

    # Render results view
    render :bulk_create
  end

  def edit
    load_available_tags
  end

  def update
    if @credential.update(credential_params)
      flash[:notice] = "Credential updated successfully."
      redirect_to @credential
    else
      load_available_tags
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
    AnalyzeCredentialJob.perform_later(@credential.id)
    flash[:notice] = "AI analysis has been re-triggered for this credential."
    redirect_to @credential
  end

  def bulk_share
    credential_ids = params[:credential_ids]&.reject(&:blank?)

    if credential_ids.blank?
      flash[:alert] = "Please select at least one credential to share"
      redirect_to credentials_path and return
    end

    @credentials = current_user.credentials.where(id: credential_ids)

    if @credentials.empty?
      flash[:alert] = "No valid credentials selected"
      redirect_to credentials_path and return
    end

    recipient_email = params[:recipient_email]
    message = params[:message]

    # Send credentials via email using a background job
    CredentialBulkShareJob.perform_later(
      credential_ids: @credentials.pluck(:id),
      recipient_email: recipient_email,
      sender_id: current_user.id,
      message: message
    )

    flash[:notice] = "Credentials are being prepared and will be sent to #{recipient_email} shortly."
    redirect_to credentials_path
  end

  private

  def set_credential
    @credential = current_user.credentials.find(params[:id])
  end

  def credential_params
    params.require(:credential).permit(:title, :start_date, :end_date, :notes, :file, tag_ids: [])
  end

  def load_available_tags
    @available_tags = Tag.default_tags.or(Tag.user_tags(current_user)).alphabetical
  end
end
