class CreateCheckoutBooksTable < ActiveRecord::Migration[6.1]
  def change
    create_table :checkout_books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :checkout_date
      t.datetime :return_date
      t.timestamps
    end
  end
end
