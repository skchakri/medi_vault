class ShortUrlsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @short_url = ShortUrl.find_by_token!(params[:token])
    @short_url.increment_click_count!

    redirect_to @short_url.original_url, allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    render plain: "Short URL not found", status: :not_found
  end
end
