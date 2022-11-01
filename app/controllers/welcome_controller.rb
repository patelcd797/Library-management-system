class WelcomeController < ApplicationController 
    before_action :logged_in_user?, only: [:index] 
    def index 
    end

    private
    def logged_in_user?
        if logged_in?
            redirect_to books_path
        end
    end
   
end