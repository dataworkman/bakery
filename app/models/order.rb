class Order < ApplicationRecord
  has_one_attached :cake_image

  STORES = [ "Suwanee", "Johns Creek", "Duluth", "Doraville", "Riverdale" ].freeze

  validates :store_name, presence: true
  validates :manager_name, presence: true
  validates :order_date, presence: true
  validates :pickup_date, presence: true
  validates :customer_name, presence: true

  before_validation :generate_order_number, on: :create

  private

  def generate_order_number
    return if order_number.present?

    store_code = store_name.to_s.gsub(/\s+/, "").first(3).upcase
    date_code = (order_date || Date.today).strftime("%Y%m%d")
    random_str = SecureRandom.alphanumeric(4).upcase

    self.order_number = "#{date_code}-#{store_code}-#{random_str}"
  end
end
