require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def valid_attributes(overrides = {})
    { store_name: "Duluth", manager_name: "Kim", order_date: Date.new(2026, 4, 3),
      pickup_date: Time.zone.local(2026, 4, 5, 10), customer_name: "Lee" }.merge(overrides)
  end

  test "is valid with required attributes" do
    assert Order.new(valid_attributes).valid?
  end

  test "requires the core fields" do
    %i[store_name manager_name order_date pickup_date customer_name].each do |field|
      order = Order.new(valid_attributes(field => nil))
      assert_not order.valid?, "expected #{field} to be required"
      assert order.errors.of_kind?(field, :blank)
    end
  end

  test "rejects a store that is not in the list" do
    order = Order.new(valid_attributes(store_name: "Nowhere"))

    assert_not order.valid?
    assert order.errors.of_kind?(:store_name, :inclusion)
  end

  test "generates an order number on create" do
    order = Order.create!(valid_attributes(store_name: "Johns Creek"))

    assert_match(/\A20260403-JOH-[A-Z0-9]{4}\z/, order.order_number)
  end

  test "rejects a duplicate order number" do
    existing = orders(:one)
    order = Order.new(valid_attributes(order_number: existing.order_number))

    assert_not order.valid?
    assert order.errors.of_kind?(:order_number, :taken)
  end

  test "accepts a PNG cake image" do
    order = Order.new(valid_attributes)
    order.cake_image.attach(io: file_fixture("cake.png").open, filename: "cake.png", content_type: "image/png")

    assert order.valid?, order.errors.full_messages.to_sentence
  end

  test "rejects a non-image cake image even if it claims to be a PNG" do
    order = Order.new(valid_attributes)
    order.cake_image.attach(io: file_fixture("not_an_image.html").open, filename: "cake.png", content_type: "image/png")

    assert_not order.valid?
    assert_includes order.errors[:cake_image].join, "must be a JPEG"
  end

  test "rejects a cake image over the size limit" do
    order = Order.new(valid_attributes)
    oversized = file_fixture("cake.png").binread + "\0" * (Order::MAX_CAKE_IMAGE_SIZE + 1)
    order.cake_image.attach(io: StringIO.new(oversized), filename: "cake.png", content_type: "image/png")

    assert_not order.valid?
    assert_includes order.errors[:cake_image].join, "smaller than 10 MB"
  end

  test "an order without a new image stays valid" do
    assert orders(:one).valid?
  end

  test "generated order numbers never collide with an existing one" do
    taken = Order.create!(valid_attributes)
    suffix = taken.order_number.split("-").last
    fresh = %w[ ZZZZ ]
    values = [ suffix, suffix, *fresh ] # two collisions, then a free value

    original = SecureRandom.method(:alphanumeric)
    SecureRandom.define_singleton_method(:alphanumeric) { |*| values.shift || original.call(4) }
    begin
      order = Order.create!(valid_attributes)
    ensure
      SecureRandom.define_singleton_method(:alphanumeric, original)
    end

    assert_equal "20260403-DUL-ZZZZ", order.order_number
    assert_not_equal taken.order_number, order.order_number
  end

  test "database rejects duplicate order numbers" do
    existing = orders(:one)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Order.new(valid_attributes(order_number: existing.order_number)).save!(validate: false)
    end
  end
end
