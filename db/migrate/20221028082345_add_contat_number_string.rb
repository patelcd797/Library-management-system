class AddContatNumberString < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :contact_number
    add_column :users, :contact_number, :string
  end
end
