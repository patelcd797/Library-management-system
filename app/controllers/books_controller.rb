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
        @books = Book.search(search).paginate(page: params[:page], per_page: 3)
        
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
        # number of books update 
        if @book.no_of_books != params[:book][:no_of_books]
            no_of_books_checkout = @book.no_of_books - @book.no_of_books_available 
            updated_no_of_books = params[:book][:no_of_books].to_i

            if no_of_books_checkout > updated_no_of_books
                flash[:alert] = "You can't make the no of books less #{no_of_books_checkout}"
                redirect_to edit_book_path
                return
            end
            
            @book.no_of_books_available = updated_no_of_books - no_of_books_checkout
        end

        if @book.update(book_param)
            flash[:notice] = "Book information updated successfully!"
            redirect_to @book
        else
            flash[:alert] = "Some error occured. please try again"
            redirect_to edit_book_path
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