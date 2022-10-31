class AddContactNumberNumber < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :contact_number
    add_column :users, :contact_number, :contact_number
    remove_column :users, :admin
    add_column :users, :admin, :boolean, default: false 
  end
end
