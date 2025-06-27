class Agent < ApplicationRecord
  has_secure_password

  # Enums
  # enum role: {
  #   ADMIN: "ADMIN",
  #   SUPERADMIN: "SUPERADMIN"
  # }
  #
  #   enum role: {
  #   admin: "ADMIN",
  #   superadmin: "SUPERADMIN"
  # }

  # enum role: {
  #   admin: "ADMIN",
  #   superadmin: "SUPERADMIN"
  # }, _prefix: true

  # Validations
  validates :firstname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[ADMIN SUPERADMIN] }

  # Associations
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assigned_to_id"
  has_many :comments, as: :created_by, dependent: :destroy

  # Callbacks
  before_save :downcase_email

  # Scopes
  scope :admins, -> { where(role: "ADMIN") }
  scope :superadmins, -> { where(role: "SUPERADMIN") }

  # Instance methods
  def full_name
    "#{firstname} #{lastname}"
  end

  def active_assigned_tickets
    assigned_tickets.where(status: [ "ACTIVE", "ESCALATED" ])
  end

  def is_superadmin?
    role == "SUPERADMIN"
  end

  def is_admin?
    role == "ADMIN"
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
