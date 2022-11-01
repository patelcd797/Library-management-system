class UsersController < ApplicationController
    before_action :required_login, except: [:new, :create]
    before_action :set_user, only: [:edit, :show, :update, :destroy]
    before_action :same_user, only: [:edit, :update]
    before_action :requires_same_user_or_admin, only: [:destroy]
    before_action :borrowed_book?, only: [:destroy]

    def show
        @borrowed_books = borrowed_book
        @wishlisted_books = wishlisted_books
    end

    def new
        @user = User.new
    end

    def edit 
    end

    def checkout
        @books = current_user.books.paginate(page: params[:page], per_page: 3)
    end

    def create
        @user  = User.new(user_param)
        puts @user.contact_number
        if @user.save
            session[:user_id] = @user.id
            flash[:notice] = "User successfully created"
            redirect_to books_path
        else 
            puts @user.errors.messages
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
        session[:user_id] = nil
        @user.destroy
        redirect_to login_path 
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
        puts "function called"
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
        if (current_user!= @user && !current_user.admin?) || current_user.id != @user.id
            flash[:alert] = "You can't perfome this operation. p"
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
end