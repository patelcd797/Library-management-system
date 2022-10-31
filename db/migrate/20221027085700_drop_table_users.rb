class DropTableUsers < ActiveRecord::Migration[6.1]
  def change
    drop_table :table_users
  end
end
