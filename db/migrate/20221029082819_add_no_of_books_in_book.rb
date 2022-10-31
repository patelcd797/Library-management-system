class AddNoOfBooksInBook < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :no_of_books, :integer, default: 1
    add_column :books, :no_of_books_available, :integer, default: 1
  end
end
