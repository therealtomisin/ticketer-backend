class Comment < ApplicationRecord
  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :created_by_id, presence: true
  validates :created_by_type, presence: true
  validates :ticket_id, presence: true

  # Associations
  belongs_to :created_by, polymorphic: true
  belongs_to :ticket

  # Scopes
  scope :active, -> { where(is_deleted: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def author_name
    case created_by_type
    when "User"
      created_by.full_name
    when "Agent"
      "#{created_by.full_name} (#{created_by.role})"
    else
      "Unknown"
    end
  end

  def soft_delete!
    update!(is_deleted: true)
  end

  def restore!
    update!(is_deleted: false)
  end

  def is_deleted?
    is_deleted
  end

  def is_by_user?
    created_by_type == "User"
  end

  def is_by_agent?
    created_by_type == "Agent"
  end
end
