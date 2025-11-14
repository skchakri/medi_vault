# frozen_string_literal: true

class Tag < ApplicationRecord
  # Constants
  TAG_COLORS = [
    '#EF4444', # red-500
    '#F59E0B', # amber-500
    '#10B981', # emerald-500
    '#3B82F6', # blue-500
    '#8B5CF6', # violet-500
    '#EC4899', # pink-500
    '#06B6D4', # cyan-500
    '#84CC16'  # lime-500
  ].freeze

  # Associations
  has_many :credential_tags, dependent: :destroy
  has_many :credentials, through: :credential_tags
  belongs_to :user, optional: true

  # Validations
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 50 },
                   format: { with: /\A[a-z0-9\-_\s]+\z/i, message: "only allows letters, numbers, hyphens, underscores, and spaces" }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color code" }

  # Scopes
  scope :default_tags, -> { where(is_default: true, active: true) }
  scope :user_tags, ->(user) { where(user: user, active: true) }
  scope :popular, -> { where('usage_count > 0').order(usage_count: :desc) }
  scope :alphabetical, -> { order(:name) }
  scope :active, -> { where(active: true) }

  # Callbacks
  before_validation :normalize_name
  before_create :assign_color, unless: :color?

  private

  def normalize_name
    self.name = name.to_s.strip.downcase if name
  end

  def assign_color
    # Rotate through predefined colors based on existing count
    existing_count = Tag.count
    self.color = TAG_COLORS[existing_count % TAG_COLORS.length]
  end
end
