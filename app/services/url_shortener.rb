# frozen_string_literal: true

class UrlShortener
  attr_reader :original_url, :short_url

  def initialize(original_url)
    @original_url = original_url
  end

  # Creates or finds an existing short URL
  def shorten
    @short_url = ShortUrl.find_or_create_by(original_url: original_url)
    self
  end

  # Returns the short URL path
  def short_path
    return nil unless @short_url

    "/s/#{@short_url.token}"
  end

  # Returns the full short URL with protocol and host
  def full_url(request = nil)
    return nil unless @short_url

    @short_url.short_url(request)
  end

  # Class method for convenience
  def self.shorten(original_url)
    new(original_url).shorten
  end

  # Class method to get short path directly
  def self.short_path_for(original_url)
    shorten(original_url).short_path
  end

  # Class method to get full URL directly
  def self.full_url_for(original_url, request = nil)
    shorten(original_url).full_url(request)
  end
end
