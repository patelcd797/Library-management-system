class CheckoutBook < ApplicationRecord
    belongs_to :user
    belongs_to :book
    
    def self.show_return_button?(params)
        user =params[:user]
        book = params[:book]
        checkout_book = find_by(user_id: user.id,book_id:book.id)
        return checkout_book.return_date <= Date.today if checkout_book
        false
    end
end