class ThemeSetting < ApplicationRecord
  has_one_attached :logo

  # Validations
  validates :primary_color, :secondary_color, :font_family, presence: true
  validates :primary_color, :secondary_color, format: { with: /\A#[0-9A-F]{6}\z/i, message: "must be a valid hex color (e.g., #7E22CE)" }
  validates :font_family, inclusion: { in: %w[system arial helvetica georgia times courier verdana] }

  # Singleton pattern - only one ThemeSetting record should exist
  def self.instance
    first_or_create!(
      primary_color: "#7E22CE",    # Default purple from current design
      secondary_color: "#9333EA",  # Lighter purple
      font_family: "system"
    )
  end

  def self.current
    instance
  end
end
