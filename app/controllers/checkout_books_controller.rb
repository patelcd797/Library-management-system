class CheckoutBooksController < ApplicationController
    before_action :required_login
    before_action :book_exist?, only: [:create]
    before_action :already_borrowed?, only: [:create]
    before_action :book_is_available?, only: [:create]
    before_action :reach_maximum_limit?, only: [:create]

    def create
        @book = Book.find(params[:book])
        @book.no_of_books_available = @book.no_of_books_available - 1
        @book.save
        reserve_book = ReserveBook.find_by(user_id: current_user.id, book_id: @book.id)

        if reserve_book
            reserve_book.destroy
        end 

        @checkout_book = CheckoutBook.create(user: current_user, book: @book, checkout_date:  Date.current(), return_date: Date.current() + 5.days)
        flash[:notice] = "Book successfully added"
        redirect_to users_checkout_path
    end

    def update
        book = Book.find(params[:id])
        if book
            checkout_book = CheckoutBook.find_by(user_id: current_user.id, book_id: book.id)
            if checkout_book.update(checkout_date: Date.current(), return_date: Date.current() + 5.days)
                flash[:notice] = "Book successfully renewed"
                redirect_to users_checkout_path
            else
                flash[:alert] = "some error occured pleasetry again"
                redirect_to users_checkout_pat
            end 
        else
            flash[:alert] = "You can't perform this operation. details is wrong"
            redirect_to request.referrer
        end 
    end

    def destroy
        book = Book.find(params[:id])
        if book
            book.no_of_books_available = book.no_of_books_available + 1
            book.save
            checkout_book = CheckoutBook.find_by(user_id: current_user.id, book_id: book.id)
            checkout_book.destroy
            flash[:notice] = "Book successfully returned"

            wishlisted_users = wishlisted_user_mail_not(book)
            if wishlisted_users.size > 0 
                UserMailer.with(book: book, users: wishlisted_users).book_is_available.deliver_now
            end
            redirect_to users_checkout_path
        else 
            flash[:alert] = "You can't perform this operation. details is wrong"
            redirect_to request.referrer
        end
    end

    private 
    def required_login
        if !logged_in?
            flash[:alert] = "You need to login before performing this action"
            redirect_to login_path
        end
    end

    def already_borrowed? 
        @book = Book.find(params[:book])
        if current_user.books.include?(@book)
            flash[:alert] = "you already borrowed book!"
            redirect_to request.referrer
        end
    end

    def book_exist?
        if !Book.find(params[:book])
            flash[:alert] = "You can;t perform this operation. details is wrong"
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

    def wishlisted_user_mail_not(book)
        user_list = []
        book.wishlisted_users.each { |user| 
            reserve_book = ReserveBook.find_by(user_id: user.id, book_id: book.id)
            if !reserve_book.mail_sent
                reserve_book.mail_sent = true
                reserve_book.save
                user_list.push(user)
            end
        }
        user_list
    end
end