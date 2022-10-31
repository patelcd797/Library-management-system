class CreateCheckoutBooksTable < ActiveRecord::Migration[6.1]
  def change
    create_table :checkout_books_tables do |t|

      t.timestamps
    end
  end
end
