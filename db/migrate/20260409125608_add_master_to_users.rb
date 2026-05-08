class AddMasterToUsers < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:users, :master)
      add_column :users, :master, :boolean, default: false
    end
  end
end
