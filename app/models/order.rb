class Order < ApplicationRecord
  has_one_attached :cake_image

  STORES = [ "Suwanee", "Johns Creek", "Duluth", "Doraville", "Riverdale" ].freeze
  CAKE_IMAGE_TYPES = %w[ image/jpeg image/png image/webp image/gif ].freeze
  MAX_CAKE_IMAGE_SIZE = 10.megabytes

  validates :store_name, presence: true, inclusion: { in: STORES, allow_blank: true }
  validates :manager_name, presence: true
  validates :order_date, presence: true
  validates :pickup_date, presence: true
  validates :customer_name, presence: true
  validates :order_number, uniqueness: true, allow_nil: true

  validate :cake_image_is_acceptable

  before_validation :generate_order_number, on: :create

  private

  # Only checks a newly attached file, so orders that already have an image stay editable.
  def cake_image_is_acceptable
    return unless attachment_changes["cake_image"] && cake_image.attached?

    unless cake_image.content_type.in?(CAKE_IMAGE_TYPES)
      errors.add(:cake_image, "must be a JPEG, PNG, WebP or GIF image (iPhone HEIC photos are not supported)")
    end

    if cake_image.byte_size > MAX_CAKE_IMAGE_SIZE
      errors.add(:cake_image, "must be smaller than #{MAX_CAKE_IMAGE_SIZE / 1.megabyte} MB")
    end
  end

  def generate_order_number
    return if order_number.present?

    store_code = store_name.to_s.gsub(/\s+/, "").first(3).upcase
    date_code = (order_date || Date.today).strftime("%Y%m%d")

    loop do
      self.order_number = "#{date_code}-#{store_code}-#{SecureRandom.alphanumeric(4).upcase}"
      break unless Order.exists?(order_number: order_number)
    end
  end
end
