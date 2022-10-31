class CreateBookTable < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title 
      t.string :description
      t.string :author 
      t.string :price
      t.string :language
      t.timestamps
    end
  end
end
