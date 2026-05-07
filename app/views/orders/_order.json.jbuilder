json.extract! order, :id, :order_number, :store_name, :manager_name, :order_date, :pickup_date, :customer_name, :cake_description, :created_at, :updated_at
json.url order_url(order, format: :json)
