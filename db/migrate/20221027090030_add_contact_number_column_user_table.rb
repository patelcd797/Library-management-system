class AddContactNumberColumnUserTable < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :contact_number, :string
    remove_column :users, :contace_number
  end
end
