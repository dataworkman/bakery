require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { cake_description: @order.cake_description, customer_name: @order.customer_name, manager_name: @order.manager_name, order_date: @order.order_date, order_number: @order.order_number, pickup_date: @order.pickup_date, store_name: @order.store_name } }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { cake_description: @order.cake_description, customer_name: @order.customer_name, manager_name: @order.manager_name, order_date: @order.order_date, order_number: @order.order_number, pickup_date: @order.pickup_date, store_name: @order.store_name } }
    assert_redirected_to order_url(@order)
  end

  test "master can destroy order" do
    sign_in_as(users(:admin))

    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end

  test "non-master cannot destroy order" do
    assert_no_difference("Order.count") do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end

  test "create ignores a client-supplied order number" do
    post orders_url, params: { order: { order_number: "HACKED", cake_description: "x", customer_name: "x", manager_name: "x", order_date: Date.today, pickup_date: Time.current, store_name: "Duluth" } }

    assert_not_equal "HACKED", Order.last.order_number
  end

  test "create rejects an unknown store" do
    assert_no_difference("Order.count") do
      post orders_url, params: { order: { cake_description: "x", customer_name: "x", manager_name: "x", order_date: Date.today, pickup_date: Time.current, store_name: "Nowhere" } }
    end

    assert_response :unprocessable_entity
  end

  test "index paginates orders" do
    (OrdersController::PER_PAGE + 5).times do |i|
      Order.create!(store_name: "Duluth", manager_name: "m", customer_name: "Customer#{i}", order_date: Date.today, pickup_date: Time.current)
    end

    get orders_url
    assert_response :success
    assert_select "nav[aria-label=Pagination]"
    assert_select "a", text: /Next/

    get orders_url(page: 2)
    assert_response :success
    assert_select "a", text: /Previous/

    get orders_url(page: 999)
    assert_response :success
  end

  test "unauthenticated visitors cannot open the order form" do
    sign_out
    get new_order_url
    assert_redirected_to new_session_url
  end

  test "unauthenticated visitors cannot create orders" do
    sign_out
    assert_no_difference("Order.count") do
      post orders_url, params: { order: { cake_description: "x", customer_name: "x", manager_name: "x", order_date: Date.today, pickup_date: Time.current, store_name: "Duluth" } }
    end
    assert_redirected_to new_session_url
  end

  # Listing explicit types (not image/*) makes iOS Safari convert HEIC photos to JPEG on upload.
  test "image field lists explicit types so iPhones convert HEIC to JPEG" do
    get new_order_url

    assert_select "input[type=file][accept='image/jpeg,image/png,image/webp,image/gif']"
  end

  test "create with a valid cake image" do
    assert_difference("Order.count") do
      post orders_url, params: { order: order_params.merge(cake_image: fixture_file_upload("cake.png", "image/png")) }
    end

    assert Order.last.cake_image.attached?
  end

  test "create rejects a non-image upload" do
    assert_no_difference("Order.count") do
      post orders_url, params: { order: order_params.merge(cake_image: fixture_file_upload("not_an_image.html", "text/html")) }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Cake image must be a JPEG/
  end

  private

  def order_params
    { cake_description: "x", customer_name: "x", manager_name: "x", order_date: Date.today, pickup_date: Time.current, store_name: "Duluth" }
  end
end
