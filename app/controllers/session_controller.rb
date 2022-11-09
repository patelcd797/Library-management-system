class SessionController < ApplicationController 
    def new 
    end

    def create
        user  = User.search(params[:session][:user_name])

        if user && user.authenticate(params[:session][:password])
            session[:user_id] = user.id
            redirect_to books_path
        else 
            flash[:alert] = "User name and password not matches"
            render 'session/new'
        end
    end

    def destroy
        session[:user_id] = nil
        redirect_to root_path
    end

    private
    def session_param
        params.required(:session).permit(:user_name, :password)
    end
end