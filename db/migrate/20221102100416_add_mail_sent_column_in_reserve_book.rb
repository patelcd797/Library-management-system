class AddMailSentColumnInReserveBook < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_books, :mail_sent, :boolean, default: false
  end
end
