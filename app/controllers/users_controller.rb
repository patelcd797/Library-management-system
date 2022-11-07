class UsersController < ApplicationController
    CHECKOUT_RECORD_TYPE = 1
    WISHLIST_RECORD_TYPE = 2

    before_action :required_login, except: [:new, :create]
    before_action :set_user, only: [:edit, :show, :update, :destroy]
    before_action :same_user, only: [:edit, :update]
    before_action :requires_same_user_or_admin, only: [:destroy]
    before_action :borrowed_book?, only: [:destroy]
    before_action :admin_user?, only: [:index]

    def index
        @users = User.all 
    end
    def show
        @checkout_book_record = UserRecord.where("user_id=#{@user.id} AND record_type=#{CHECKOUT_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: Time.now.prev_year.next_month.at_beginning_of_month..Time.now).count
        @checkout_book_record.shift
        @checkout_book_record_exist = false
        @checkout_book_record.each {|key, value| @checkout_book_record_exist =true if value!=0 }

        @wishlist_book_record = UserRecord.where("user_id=#{@user.id} AND record_type=#{WISHLIST_RECORD_TYPE}").group_by_month(:created_at, format: "%b %y", range: Time.now.prev_year.next_month.at_beginning_of_month..Time.now).count
        @wishlist_book_record.shift
        @wishlist_book_record_exist = false
        @wishlist_book_record.each {|key, value| @wishlist_book_record_exist =true if value!=0 }

        @borrowed_books = borrowed_book
        @wishlisted_books = wishlisted_books
    end

    def new
        @user = User.new
    end

    def edit 
    end

    def search
        search = params[:search][:search]
        search.strip!
        @users = User.search_user(search)

        respond_to do |format|
            format.js { render 'users/results'}
            format.html { render login_path }
        end
    end

    def checkout
        @books = current_user.books.paginate(page: params[:page], per_page: 3)
    end

    def create
        @user  = User.new(user_param)
        if @user.save
            session[:user_id] = @user.id
            flash[:notice] = "User successfully created"
            UserMailer.with(user: @user).welcome_mail.deliver_now
            redirect_to books_path
        else 
            @message = ""
            if @user.errors.messages[:email].include? "has already been taken"
                @message = "Email is already in use"
            elsif @user.errors.messages[:contact_number].include? "has already been taken"
                @message = "Contact number is already in use"
            else 
                @field_required = []
                @user.errors.each { |key, value| 
                    @field_required.push(key) if value.include? "can't be blank" 
                }

                if @field_required.size > 1
                    @field_required.each { |key| @message = @message + (key.to_s).split('_').join(" ") + " " }
                    if(@field_required.size > 1)
                        @message = @message + "are"
                    else 
                        @message = @message + "is"
                    end
                    @message = @message + " required"
                else 
                    @message = "Some error occured please try again"
                end
            end
            flash[:alert] = @message
            redirect_to signup_path
        end
    end


    def update 
        if @user.update(user_param)
            flash[:notice] = "User information updated successfully"
            redirect_to @user
        else 
            flash[:alert] = "Some error occured please try again"
            render 'users/edit'
        end
    end

    def destroy
        if current_user == @user
            session[:user_id] = nil
            @user.destroy
            redirect_to login_path 
        else 
            @user.destroy
            redirect_to users_path
        end
    end

    private 
    def user_param
        params.require(:user).permit(:first_name, :last_name, :email, :password, :contact_number, :image)
    end

    def set_user
        @user = User.find(params[:id])
    end

    def same_user
        if current_user != @user
            flash[:alert] = "You can't edit or update the profile"
            redirect_to @user
        end
    end

    def required_login
        if !logged_in?
            flash[:alert] = "You can't perfome this operation. please login and try again"
            redirect_to login_path
        end
    end

    def borrowed_book? 
        if @user.books.any?
            flash[:alert] = "Return all the borrowed books"
            redirect_to books_path
        end
    end
    def requires_same_user_or_admin
        if (current_user!= @user && !current_user.admin?)
            flash[:alert] = "You can't perfome this operation."
            redirect_to request.referrer
        end 
    end
    
    def borrowed_book
        @borrowed_books = []
        @user.books.each { |book|
            checkout_book = CheckoutBook.find_by(user_id: @user.id, book_id: book.id) 
            borrow_book = { title: book.title, 
                            checkout_date: checkout_book.checkout_date, 
                            return_date: checkout_book.return_date
                        }
            @borrowed_books.push(borrow_book)
        }
        @borrowed_books
    end

    def wishlisted_books
        @wishlisted_books = []
        @user.reserve_books.each { |book|
            reserve_book = ReserveBook.find_by(user_id: @user.id, book_id: book.id) 
            wishlist_book = { title: book.title, wishlist_date: reserve_book.created_at }
            @wishlisted_books.push(wishlist_book)
        }
        @wishlisted_books
    end

    def admin_user?
        if !current_user.admin
            redirect_to current_user
        end
    end
end