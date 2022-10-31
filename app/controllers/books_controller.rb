class BooksController < ApplicationController
    before_action :required_login
    before_action :required_admin_user, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_book, only: [:edit, :show, :update] 
    def index
        @books = Book.paginate(page: params[:page], per_page: 3)
    end

    def new
        @book = Book.new
    end

    def edit
    end

    def show
    end

    def search 
        search = params[:search][:search]
        search.strip!
        if search.empty?
            @books = Book.all
        else 
            @books = Book.search(search)
        end
        
        respond_to do |format|
            format.js { render 'books/results'}
            format.html { render new_book_path }
        end
    end

    def create
        @book = Book.new(book_param)
        @book.no_of_books_available = @book.no_of_books
        if @book.save 
            flash[:notice] = "Book added successfully!"
            redirect_to books_path
        else
            flash[:alert] = "Some error occured please try again"
            render 'books/new'
        end
    end

    def update
        @book.no_of_books_available = params[:book][:no_of_books] 
        if @book.update(book_param)
            flash[:notice] = "Book information updated successfully!"
            redirect_to books_path
        else
            flash[:alert] = "Some error occured. please try again"
            render 'books/edit'
        end
    end
    private 

    def set_book
        @book = Book.find(params[:id]) 
    end

    def book_param
        params.required(:book).permit(:title, :description, :price,:author, :language, :no_of_books, :image)
    end

    def required_login
        if !logged_in? 
            flash[:alert] = "You can't perfome this operartion. login and try again"
            redirect_to root_path
        end
    end

    def required_admin_user
        if !current_user.admin?
            flash[:alert] = "You can't perform this operation!"
            redirect_to books_path
        end
    end

end