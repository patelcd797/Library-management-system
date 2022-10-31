class UsersController < ApplicationController
    before_action :required_login
    before_action :set_user, only: [:edit, :show, :update]
    before_action :same_user, only: [:edit, :update]

    def show
    end

    def new
        @user = User.new
    end

    def edit 
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
                flash[:alert] = @message
                render 'users/new'
            end
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

    private 
    def user_param
        p = params.require(:user).permit(:first_name, :last_name, :email, :password, :contact_number)
        puts p 
        p
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
end