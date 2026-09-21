class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :password, length: { minimum: 8 }, allow_nil: true

  # Revoking approval must also end sessions that are already signed in.
  after_update_commit :end_sessions, if: -> { saved_change_to_approved? && !approved? }

  private

  def end_sessions
    sessions.destroy_all
  end
end
