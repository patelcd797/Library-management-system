class CreteUsersTable < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :contace_number
      t.string :password_digest
      t.boolean :admin
      t.timestamps
    end
  end
end
