# frozen_string_literal: true

class ShareLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_credential, only: [:create]

  def show
    @share_link = ShareLink.find_by!(token: params[:token])

    unless @share_link.active?
      render :expired and return
    end

    @share_link.record_access!
    @credential = @share_link.credential
  end

  def create
    @credential = current_user.credentials.find(params[:credential_id])
    @share_link = @credential.share_links.create!(
      expires_at: 24.hours.from_now,
      one_time: true
    )

    flash[:notice] = "Share link created: #{@share_link.share_url}"
    redirect_to @credential
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Failed to create share link: #{e.message}"
    redirect_to @credential
  end

  private

  def set_credential
    @credential = current_user.credentials.find(params[:credential_id])
  end
end
