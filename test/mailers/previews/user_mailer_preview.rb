# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
    def book_is_available
        @book = Book.new(title: "hello", description: "i am here. do you want to read me?", price: 12.54, no_of_books: 12, author: "chintan patel", language: "english")
        # mail(to: "a@gmail.com", subject: "You got a new order!")
        UserMailer.with(book: @book).book_is_available
    end
end
