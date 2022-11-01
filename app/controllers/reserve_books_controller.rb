class ReserveBooksController < ApplicationController
    before_action :required_login
    before_action :set_user
    before_action :book_exist?, only: [:create]
    before_action :already_reserved?, only: [:create] 
    before_action :already_borrowed?, only: [:create]

    def create
        book = Book.find(params[:book])
        reserve_book = ReserveBook.create(user: current_user, book: book)
        redirect_to request.referrer
    end 

    def destroy
        book = Book.find(params[:id])
        if book
            reserve_book = ReserveBook.find_by(user_id: @user.id, book_id: book.id) 
            flash[:notice] = "Book successfully unreserved!"
            reserve_book.destroy
        else 
            flash[:alert] = "Book doesn't exist"
        end  
        redirect_to request.referrer
    end

    private

    def required_login
        if !logged_in?
            flash[:alert] = "You need to login before performing this action"
            redirect_to login_path
        end
    end

    def set_user
        @user = current_user
    end

    def book_exist?
        if !Book.find(params[:book])
            flash[:alert] = "You can't perform this operation. details is wrong"
            redirect_to request.referrer
        end
    end

    def already_reserved? 
        @book = Book.find(params[:book])
        if current_user.reserve_books.include?(@book)
            flash[:alert] = "you already reserved book!"
            redirect_to request.referrer
        end
    end

    def already_borrowed? 
        @book = Book.find(params[:book])
        if current_user.books.include?(@book)
            flash[:alert] = "you already borrowed book!"
            redirect_to request.referrer
        end
    end
end