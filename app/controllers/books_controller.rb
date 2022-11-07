class BooksController < ApplicationController
    CHECKOUT_RECORD_TYPE = 1
    WISHLIST_RECORD_TYPE = 2
    
    before_action :required_login
    before_action :required_admin_user, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_book, only: [:edit, :show, :update] 
    def index
        @books = Book.paginate(page: params[:page], per_page: 5)

        #popular books
        @checkout_books = BookRecord.where("record_type = #{CHECKOUT_RECORD_TYPE}")
        @popular_books_group = @checkout_books.group(:book_id).count
        @top_popular_books = []
        @popular_books_group.each { |key,value| 
            @top_popular_books.push({book: Book.find(key), count: value})
        }
        @top_popular_books = @top_popular_books.sort_by {|obj| obj.count}
        @top_popular_books = @top_popular_books[0, [@top_popular_books.size, 5].min]
        @popular_books = @top_popular_books.pluck(:book)

        #tranding books 
        @rated_books = Feedback.all
        @tranding_books_rating_avg = @rated_books.group(:book_id).average(:rating)

        @top_tranding_books = []
        @tranding_books_rating_avg.each do |book_id, rating|
            @top_tranding_books.push({book: Book.find(book_id), rating: rating})
        end 
        @top_tranding_books = @top_tranding_books.sort_by { |book| book.count }
        @top_tranding_books = @top_tranding_books[0, [@top_tranding_books.size, 5].min]
        @tranding_books = @top_tranding_books.pluck(:book)

        # recommended books
        @recommended_books = Feedback.all.where("recommended=#{true}")
        @recommended_books_group = @recommended_books.group(:book_id).count

        @top_recommended_books = []
        @recommended_books_group.each do |book_id, count|
            @top_recommended_books.push({book: Book.find(book_id), count: count})
        end 
        @top_recommended_books = @top_recommended_books.sort_by { |book| book.count }
        @top_recommended_books = @top_recommended_books[0, [@top_recommended_books.size, 5].min]
        @recommended_books = @top_recommended_books.pluck(:book)
       
        # Latest books 
        @latest_books = Book.where("created_at >= ?", Time.now.prev_year.next_month.at_beginning_of_month).sort_by.sort_by {|obj| obj.created_at}
        @latest_books.reverse!
        @latest_books[0,[@latest_books.size, 5].min]
        
    end

    def new
        @book = Book.new
    end

    def edit
    end

    def show
        @checkout_book_record = BookRecord.where("book_id=#{@book.id} AND record_type=#{CHECKOUT_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: Time.now.prev_year.next_month.at_beginning_of_month..Time.now).count
        @checkout_book_record.shift
        @checkout_book_record_exist = false
        @checkout_book_record.each {|key, value| @checkout_book_record_exist =true if value!=0 }

        @wishlist_book_record = BookRecord.where("book_id=#{@book.id} AND record_type=#{WISHLIST_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: Time.now.prev_year.next_month.at_beginning_of_month..Time.now).count
        @wishlist_book_record.shift
        @wishlist_book_record_exist = false
        @wishlist_book_record.each {|key, value| @wishlist_book_record_exist =true if value!=0 }

        @data = [{name: 'checout out', data: @checkout_book_record}, {name: 'wishlist', data: @wishlist_book_record}]

        @borrowed_users = checkout_users
        @wishlisted_users = wishlisted_users
    end

    def search_book 
        search = params[:search][:search]
        search.strip!
        
        if params[:search][:search_page] == "true"
            @books = Book.search(search)
            
            respond_to do |format|
                format.js { render 'books/results'}
                format.html { render new_book_path }
            end
        else 
            redirect_to search_path(search: search)
        end
    end

    def search
        @books = @books = Book.search(params[:search])
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

    def checkout_users
        @users_list = []
        @book.users.each { |user|
            checkout_book = CheckoutBook.find_by(user_id: user.id, book_id: @book.id)
            borrow_user = { first_name: user.first_name, last_name: user.last_name, 
                            checkout_date: checkout_book.checkout_date, 
                            return_date: checkout_book.return_date
                        }
            @users_list.push(borrow_user)
        }
        @users_list
    end

    def wishlisted_users
        @list = []
        @book.wishlisted_users.each { |user|
            reserve_book = ReserveBook.find_by(user_id: user.id, book_id: @book.id) 
            wishlisted_user = { first_name: user.first_name, last_name: user.last_name, 
                            whishlist_date: reserve_book.created_at
                        }
            @list.push(wishlisted_user)
        }
        @list
    end
end