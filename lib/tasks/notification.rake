namespace :notification do
  desc "Send email notification to the over due books users"
  
  task over_due_book: :environment do
    find_user = false
    CheckoutBook.all.each do |checkout_book|
      if checkout_book.return_date < Date.today
        find_user = true
        user = User.find(checkout_book.user_id)
        book = Book.find(checkout_book.book_id)
        UserMailer.with(user: user, book: book).send_over_due_notification.deliver_now 
      end 
    end
    if !find_user
      puts "no user found!"
    end
  end
end
