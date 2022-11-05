class CreateFeedbackTable < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks do |t|
      t.belongs_to :book, null: false, foreign_key: true
      t.string :user_name, default: 'anonymous'
      t.boolean :recommended, default: false
      t.integer :rating
      t.string :comment
      t.timestamps
    end
  end
end
