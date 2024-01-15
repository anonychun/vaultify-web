class UserPassword < ApplicationRecord
  belongs_to :user
  belongs_to :password

  # Viewer can only view the password
  # Editor can update the password
  # Owner view, update, and share the password
  ROLES = %w[owner editor viewer]
  validates :role, presence: true, inclusion: { in: ROLES }

  attribute :role, default: :viewer

  def editable?
    owner? || editor?
  end

  def shareable?
    owner?
  end

  def deletable?
    owner?
  end

  private

  def owner?
    role == "owner"
  end

  def viewer?
    role == "viewer"
  end

  def editor?
    role == "editor"
  end
end
