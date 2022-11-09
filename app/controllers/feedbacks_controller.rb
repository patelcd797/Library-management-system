class FeedbacksController < ApplicationController
    before_action :required_login 
    def new 
        @book_id = params[:book] 
    end 

    def create
        @feedback = Feedback.new(feedbakc_params)
        @feedback.user_name = current_user.full_name
        @feedback.book_id = params[:feedbacks][:book_id].to_i
        @feedback.recommended = params[:feedbacks][:recommended].to_i == 1 ? true : false
        puts @feedback.book_id
        if @feedback.save
            redirect_to books_path
        else
            flash[:alert] = "comments and rating is required"
            render 'feedbacks/new'
        end 
    end

    private 
    def required_login
        if !logged_in?
            flash[:alert] = "please login in!"
            redirect_to login_path
        end
    end 

    def feedbakc_params
        params.require("feedbacks").permit(:book_id,:comment, :recommend, :rating)
    end

end