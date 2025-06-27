class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :firstname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # Associations
  has_many :tickets, foreign_key: "created_by_id", dependent: :destroy
  has_many :comments, as: :created_by, dependent: :destroy

  # Callbacks
  before_save :downcase_email

  # Instance methods
  def full_name
    "#{firstname} #{lastname}"
  end

  def active_tickets
    tickets.where(status: [ "ACTIVE", "ESCALATED" ], has_user_deleted: false)
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
