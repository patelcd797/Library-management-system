class CreateBookRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :book_records do |t|
      t.references :book, null:false, foreign_key: true
      t.integer :record_type
      t.timestamps
    end
  end
end
