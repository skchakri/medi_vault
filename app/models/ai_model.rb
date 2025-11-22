class AiModel < ApplicationRecord
  PROVIDERS = %w[openai ollama].freeze

  validates :name, presence: true
  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :model_identifier, presence: true
  validate :only_one_default_model

  scope :active, -> { where(active: true) }
  scope :default, -> { where(is_default: true).first }

  before_save :unset_other_defaults, if: :is_default?

  def self.default_model
    default || active.first
  end

  private

  def only_one_default_model
    if is_default? && AiModel.where(is_default: true).where.not(id: id).exists?
      errors.add(:is_default, 'can only be set on one model at a time')
    end
  end

  def unset_other_defaults
    AiModel.where.not(id: id).update_all(is_default: false)
  end
end
