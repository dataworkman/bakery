class AddMasterToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :master, :boolean
  end
end
