class ChangeDescriptionTextAndPriceDecimal < ActiveRecord::Migration[6.1]
  def change
    change_column :books, :price, :decimal
    change_column :books, :description, :text
  end
end
