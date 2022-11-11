class BooksController < ApplicationController
    CHECKOUT_RECORD_TYPE = 1
    WISHLIST_RECORD_TYPE = 2
    
    before_action :required_login
    before_action :required_admin_user, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_book, only: [:edit, :show, :update] 
    def index
        #popular books
        @popular_books = popular_books(true) 
        
        #favourite books 
        @favourite_books = favourite_books(true)
        
        # recommended books
        @recommended_books = recommended_books(true)
       
        # Latest books 
        @latest_books = latest_books(true)
        
    end

    def new
        @book = Book.new
    end

    def edit
    end

    def show
        @checkout_book_record = BookRecord.where("book_id=#{@book.id} AND record_type=#{CHECKOUT_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count
        @checkout_book_record.shift
        @checkout_book_record_exist = false
        @checkout_book_record.each {|key, value| @checkout_book_record_exist =true if value!=0 }

        @wishlist_book_record = BookRecord.where("book_id=#{@book.id} AND record_type=#{WISHLIST_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count
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
            @search_match_found = true
            if @books.size == 0 
                @search_match_found = false
                @books = recommended_books(false)
            end
            respond_to do |format|
                format.js { render 'books/results'}
                format.html { render new_book_path }
            end
        else 
            redirect_to search_path(search: search)
        end
    end

    def search
        @books = Book.search(params[:search])
        @search_match_found = true
        if @books.size == 0 
            @search_match_found = false
            @books = recommended_books(false)
        end
    end

    def filter
        @search_match_found = true
        @books = []
        @title = ""
        filter = params[:filter]
        if filter == "most-popular"
            @title = "Most Popular Books"
            @books = popular_books(false)
        elsif filter == "most-favourite"
            @title = "Most Favourite Books"
            @books = favourite_books(false)
        elsif filter == "most-recommended"
            @title = "Most Recommended Books"
            @books = recommended_books(false)
        elsif filter == "latest"
            @title = "Most Latest Books"
            @books = latest_books(false)
        else 
            @books= Book.all
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

    def popular_books(limit)
        #popular books
        @checkout_books = BookRecord.where("record_type = #{CHECKOUT_RECORD_TYPE}")
        @popular_books_group = @checkout_books.group(:book_id).count
        @top_popular_books = []
        @popular_books_group.each { |key,value| 
            @top_popular_books.push({book: Book.find(key), count: value})
        }
        @top_popular_books = @top_popular_books.sort_by {|obj| obj[:count]}.reverse
        @top_popular_books = @top_popular_books[0, limit ? [@top_popular_books.size, 5].min : @top_popular_books.size]
        @popular_books = @top_popular_books.pluck(:book)
    end

    def favourite_books(limit)
        #favourite books 
        @rated_books = Feedback.all
        @tranding_books_rating_avg = @rated_books.group(:book_id).average(:rating)

        @top_tranding_books = []
        @tranding_books_rating_avg.each do |book_id, rating|
            @top_tranding_books.push({book: Book.find(book_id), rating: rating.round(2) })
        end 
        @top_tranding_books = @top_tranding_books.sort_by { |book| book[:rating] }.reverse
        @top_tranding_books = @top_tranding_books[0, limit ? [@top_tranding_books.size, 5].min : @top_tranding_books.size] 
        @tranding_books = @top_tranding_books.pluck(:book)
    end

    def recommended_books(limit)
        # recommended books
        @recommended_books = Feedback.all.where("recommended=#{true}")
        @recommended_books_group = @recommended_books.group(:book_id).count

        @top_recommended_books = []
        @recommended_books_group.each do |book_id, count|
            @top_recommended_books.push({book: Book.find(book_id), count: count})
        end 
        @top_recommended_books = @top_recommended_books.sort_by { |book| book[:count] }.reverse
        @top_recommended_books = @top_recommended_books[0, limit ? [@top_recommended_books.size, 5].min : @top_recommended_books.size] 
        @recommended_books = @top_recommended_books.pluck(:book)
    end

    def latest_books(limit)
        @latest_books = Book.where("created_at >= ?", 6.months.ago.at_beginning_of_month).sort_by {|obj| obj[:created_at]}.reverse
        @latest_books[0, limit ? [@latest_books.size, 5].min : @latest_books.size] 
    end
end