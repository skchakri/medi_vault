class AlertType < ApplicationRecord
  has_many :alerts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :offset_days, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :priority, numericality: { only_integer: true }
  validates :notification_channels, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(priority: :asc) }

  def self.for_plan(plan)
    active.where("user_plans IS NULL OR user_plans @> ?", [plan].to_json)
  end

  def notification_channels=(value)
    super(Array(value).compact.uniq)
  end

  def user_plans=(value)
    super(Array(value).compact.uniq)
  end
end
