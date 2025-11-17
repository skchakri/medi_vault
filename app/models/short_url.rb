class ShortUrl < ApplicationRecord
  # Callbacks
  before_validation :generate_token, on: :create

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :original_url, presence: true
  validates :click_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Class methods
  def self.find_by_token!(token)
    find_by!(token: token)
  end

  # Instance methods
  def increment_click_count!
    increment!(:click_count)
  end

  def short_url(request = nil)
    if request
      "#{request.protocol}#{request.host_with_port}/s/#{token}"
    else
      "/s/#{token}"
    end
  end

  private

  def generate_token
    return if token.present?

    loop do
      self.token = SecureRandom.alphanumeric(8)
      break unless ShortUrl.exists?(token: token)
    end
  end
end
