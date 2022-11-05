class CreateUserRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :user_records do |t|
      t.references :user, null:false, foreign_key: true
      t.integer :record_type
      t.timestamps
    end
  end
end
