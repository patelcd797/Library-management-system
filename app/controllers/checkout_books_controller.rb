class CheckoutBooksController < ApplicationController
    before_action :already_borrowed?, only: [:create]
    before_action :book_is_available?, only: [:create]
    before_action :reach_maximum_limit?, only: [:create]

    def create
        @book = Book.find(params[:book])
        @book.no_of_books_available = @book.no_of_books_available - 1
        @book.save
        @checkout_book = CheckoutBook.create(user: current_user, book: @book, checkout_date:  Date.current(), return_date: Date.current() + 5.days)
        flash[:notice] = "Book successfully added"
        redirect_to users_checkout_path
    end

    def update
        book = Book.find(params[:id])
        checkout_book = CheckoutBook.find_by(user_id: current_user.id, book_id: book.id)
        if checkout_book.update(checkout_date: Date.current(), return_date: Date.current() + 5.days)
            flash[:notice] = "Book successfully renewed"
            redirect_to users_checkout_path
        else
            flash[:alert] = "some error occured pleasetry again"
            redirect_to users_checkout_pat
        end 
    end

    def destroy
        book = Book.find(params[:id])
        book.no_of_books_available = book.no_of_books_available + 1
        book.save
        checkout_book = CheckoutBook.find_by(user_id: current_user.id, book_id: book.id)
        checkout_book.destroy
        flash[:notice] = "Book successfully returned"
        redirect_to users_checkout_path
    end

    private 

    def already_borrowed? 
        @book = Book.find(params[:book])
        if current_user.books.include?(@book)
            flash[:alert] = "you already borrowed book!"
            redirect_to request.referrer
        end
    end

    def book_is_available?
        @book = Book.find(params[:book])
        if !@book || @book.no_of_books_available == 0
            flash[:alert] = "This book is currently not available. you can add in wishlist"
            redirect_to request.referrer
        end
    end

    def reach_maximum_limit?
        if current_user.books.size >=5
            flash[:alert] = "You already borrowed 5 books. return some books and then borrow"
            redirect_to request.referrer
        end
    end
end