class UserMailer < ApplicationMailer
    def welcome_mail 
        @user= params[:user]
        mail(
            from: "201701254@daiict.ac.in",
            to: @user.email,
            subject: "Welcome #{@user.full_name}"
        )
    end
    def book_is_available
        puts params[:users] 
        @users = params[:users]
        @book = params[:book]
        emails = @users.collect(&:email).join(",")
        mail(
            from: "201701254@daiict.ac.in",
            to: emails,
            subject: "#{@book.title} is now available"
        )
    end

    def send_over_due_notification
        @user = params[:user]
        @book = params[:book]
        mail(
            from: "201701254@daiict.ac.in",
            to: @user.email,
            subject: "Please return the #{@book.title} books"
        )
    end
end
