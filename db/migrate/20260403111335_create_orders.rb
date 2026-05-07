class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number
      t.string :store_name
      t.string :manager_name
      t.date :order_date
      t.datetime :pickup_date
      t.string :customer_name
      t.text :cake_description

      t.timestamps
    end
  end
end
