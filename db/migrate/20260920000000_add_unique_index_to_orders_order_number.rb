class AddUniqueIndexToOrdersOrderNumber < ActiveRecord::Migration[8.1]
  # Standalone model so the migration does not depend on app code.
  class MigrationOrder < ActiveRecord::Base
    self.table_name = "orders"
  end

  def up
    # Blank numbers are "not assigned yet"; NULLs do not conflict in a unique index.
    MigrationOrder.where(order_number: "").update_all(order_number: nil)

    duplicated = MigrationOrder.where.not(order_number: nil)
                               .group(:order_number).having("COUNT(*) > 1").pluck(:order_number)

    duplicated.each do |number|
      # The oldest order keeps its number; the rest get a fresh one.
      MigrationOrder.where(order_number: number).order(:id).to_a.drop(1).each do |order|
        order.update_columns(order_number: unused_number_for(order))
      end
    end
    say "Renumbered duplicates for #{duplicated.size} order number(s)" if duplicated.any?

    add_index :orders, :order_number, unique: true
  end

  def down
    remove_index :orders, :order_number
  end

  private

  def unused_number_for(order)
    store_code = order.store_name.to_s.gsub(/\s+/, "").first(3).upcase
    date_code = (order.order_date || Date.today).strftime("%Y%m%d")

    loop do
      candidate = "#{date_code}-#{store_code}-#{SecureRandom.alphanumeric(4).upcase}"
      return candidate unless MigrationOrder.exists?(order_number: candidate)
    end
  end
end
