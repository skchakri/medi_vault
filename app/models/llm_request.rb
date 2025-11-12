# frozen_string_literal: true

class LlmRequest < ApplicationRecord
  belongs_to :user, optional: true

  enum :provider, { openai: 0, ollama: 1 }

  validates :provider, presence: true

  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :recent, -> { order(created_at: :desc) }

  def self.total_cost
    sum(:cost_cents) / 100.0
  end

  def self.total_tokens
    sum(:total_tokens)
  end

  def self.by_date_range(start_date, end_date)
    where(created_at: start_date..end_date)
  end

  def cost_dollars
    (cost_cents || 0) / 100.0
  end

  def mark_success!(tokens: nil, cost: nil)
    update!(
      success: true,
      total_tokens: tokens,
      cost_cents: cost
    )
  end

  def mark_failure!(error)
    update!(
      success: false,
      error_text: error
    )
  end
end
