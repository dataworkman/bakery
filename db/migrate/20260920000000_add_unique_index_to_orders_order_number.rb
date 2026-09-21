class AddUniqueIndexToOrdersOrderNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :orders, :order_number, unique: true
  end
end
