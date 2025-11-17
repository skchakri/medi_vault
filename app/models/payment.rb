class Payment < ApplicationRecord
  belongs_to :user

  # Enums
  enum :status, { pending: 0, succeeded: 1, failed: 2, refunded: 3 }

  # Validations
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :successful, -> { where(status: :succeeded) }
  scope :recent, -> { order(paid_at: :desc) }
  scope :this_year, -> { where('paid_at >= ?', Time.current.beginning_of_year) }

  # Instance methods
  def amount_dollars
    (amount_cents || 0) / 100.0
  end

  def formatted_amount
    "$#{sprintf('%.2f', amount_dollars)}"
  end

  def mark_as_succeeded!(payment_intent_id: nil, receipt_url: nil)
    update!(
      status: :succeeded,
      paid_at: Time.current,
      stripe_payment_intent_id: payment_intent_id || stripe_payment_intent_id,
      receipt_url: receipt_url || self.receipt_url
    )
  end

  def mark_as_failed!
    update!(status: :failed)
  end
end
