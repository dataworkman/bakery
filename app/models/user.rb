class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_create :auto_approve_first_user

  def master?
    self.respond_to?(:master) && !!self.master
  end

  private

  def auto_approve_first_user
    if User.count == 0
      self.approved = true
      self.master = true
    end
  end
end
