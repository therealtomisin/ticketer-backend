class Ticket < ApplicationRecord
  # Enums
  # enum status: {
  #   ACTIVE: "ACTIVE",
  #   INACTIVE: "INACTIVE",
  #   RESOLVED: "RESOLVED",
  #   CLOSED: "CLOSED",
  #   ESCALATED: "ESCALATED"
  # }

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :status, presence: true, inclusion: { in: %w[ACTIVE INACTIVE RESOLVED CLOSED ESCALATED] }
  validates :created_by_id, presence: true
  validate :deadline_cannot_be_in_the_past, if: :deadline?
  # validates :media, array: { allow_blank: true }

  # Associations
  belongs_to :created_by, class_name: "User"
  belongs_to :assigned_to, class_name: "Agent", optional: true
  has_many :comments, dependent: :destroy

  # Callbacks
  # before_save :serialize_media
  # after_find :deserialize_media

  # Scopes
  scope :active, -> { where(status: "ACTIVE") }
  scope :assigned, -> { where.not(assigned_to: nil) }
  scope :unassigned, -> { where(assigned_to: nil) }
  scope :not_deleted_by_user, -> { where(has_user_deleted: false) }
  scope :overdue, -> { where("deadline < ?", Time.current) }
  scope :unassigned, -> { where(assigned_to_id: nil) }
  scope :assigned, -> { where.not(assigned_to_id: nil) }

  # Instance methods
  DELETED_STATUSES = %w[DELETED RESOLVED]

  def is_overdue?
    deadline.present? && deadline < Time.current
  end

  def is_assigned?
    assigned_to.present?
  end

  def can_be_resolved?
    %w[ACTIVE ESCALATED].include?(status)
  end

  def can_be_closed?
    status == "RESOLVED"
  end

  def media_files
    @media_files || []
  end

  def media_files=(files)
    @media_files = files.is_a?(Array) ? files : [ files ].compact
  end

  def add_media_file(file_url)
    current_media = media_files
    current_media << file_url unless current_media.include?(file_url)
    self.media_files = current_media
  end

  def remove_media_file(file_url)
    current_media = media_files
    current_media.delete(file_url)
    self.media_files = current_media
  end

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline < Time.current

    errors.add(:deadline, "can't be in the past")
  end

  def serialize_media
    self.media = (@media_files || []).to_json if @media_files
  end

  def deserialize_media
    @media_files = media.present? ? JSON.parse(media) : []
  rescue JSON::ParserError
    @media_files = []
  end
end
