class SupportMessage < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: 'SupportMessage', optional: true
  has_many :replies, class_name: 'SupportMessage', foreign_key: 'parent_id', dependent: :destroy

  # Validations
  validates :message, presence: true, length: { maximum: 2000 }
  validates :is_admin_response, inclusion: { in: [true, false] }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :user_messages, -> { where(is_admin_response: false) }
  scope :admin_responses, -> { where(is_admin_response: true) }
  scope :root_messages, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  # Instance methods
  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def unread?
    read_at.nil?
  end

  def read?
    !unread?
  end

  def root_message
    return self if parent_id.nil?
    parent.root_message
  end

  def conversation_thread
    root = root_message
    [root] + root.replies.order(created_at: :asc)
  end

  def conversation_preview
    message.truncate(100)
  end

  # Class methods
  def self.unread_count_for_admin
    user_messages.unread.count
  end

  def self.unread_count_for_user(user)
    admin_responses.where(user: user).unread.count
  end

  def self.conversations_for_user(user)
    for_user(user).root_messages.includes(:replies).recent
  end

  def self.conversations_for_admin
    root_messages.includes(:user, :replies).recent
  end
end
