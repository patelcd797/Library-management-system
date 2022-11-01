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
        @borrowed_users = []
        @book.users.each { |user|
            checkout_book = CheckoutBook.find_by(user_id: user.id, book_id: @book.id) 
            puts checkout_book
            borrow_user = { first_name: user.first_name, last_name: user.last_name, 
                            checkout_date: checkout_book.checkout_date, 
                            return_date: checkout_book.return_date
                        }
            @borrowed_users.push(borrow_user)
        }
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

    def destroy
        book = Book.find(params[:id])
        if book.no_of_books == book.no_of_books_available
            book.destroy
            flash[:notice] = "Book successfully removed"
            redirect_to books_path
        else
            flash[:alert] = "Currently some users borrowed this book. remove aafter all the books available"
            redirect_to request.referrer
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