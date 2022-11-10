class AnalysisController < ApplicationController
    CHECKOUT_RECORD_TYPE = 1
    WISHLIST_RECORD_TYPE = 2

    before_action :required_admin, only: [:index]

    def index

        @books_record_since_one_year = BookRecord.where("created_at >= ?", 6.months.ago.at_beginning_of_month)
        
        # checkout books
        @checkout_books = @books_record_since_one_year.where("record_type = #{CHECKOUT_RECORD_TYPE}")
        @checkout_book_record = @checkout_books.group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count
        @checkout_book_record.shift
        @checkout_book_record_exist = false

        @checkout_book_record.each {|key, value| @checkout_book_record_exist =true if value!=0 }
        @top_checkout_books_group = @checkout_books.group(:book_id).count

        @top_checkout_books = []
        @top_checkout_books_group.each { |key,value| 
            @top_checkout_books.push({name: Book.find(key).title, count: value})
        }
        @top_checkout_books = @top_checkout_books.sort_by {|obj| obj[:count]}.reverse
        @top_checkout_books = @top_checkout_books[0, [@top_checkout_books.size, 5].min]

        # wishlist books
        @wishlist_books = @books_record_since_one_year.where("record_type = #{WISHLIST_RECORD_TYPE}")
        @wishlist_book_record = @wishlist_books.group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count

        @wishlist_book_record.shift
        @wishlist_book_record_exist = false
        @wishlist_book_record.each {|key, value| @wishlist_book_record_exist =true if value!=0 }

        
        @top_wishlist_books_group = @wishlist_books.group(:book_id).count

        @top_wishlist_books = []
        @top_wishlist_books_group.each { |key,value| 
            @top_wishlist_books.push({name: Book.find(key).title, count: value})
        }
        @top_wishlist_books = @top_wishlist_books.sort_by {|obj| obj[:count]}.reverse
        @top_wishlist_books = @top_wishlist_books[0, [@top_wishlist_books.size, 5].min]
         
        # group checkout book and wishlist book
        @books_data = [{name: 'checout out', data: @checkout_book_record}, {name: 'wishlist', data: @wishlist_book_record}]

        # recommended books
        @feedbacks_record_since_one_year = Feedback.where("created_at >= ?", 6.months.ago.at_beginning_of_month)

        @recommended_books = @feedbacks_record_since_one_year.where("recommended=#{true}")
        @recommended_books_group = @recommended_books.group(:book_id).count

        @top_recommended_books = []
        @recommended_books_group.each do |book_id, count|
            @top_recommended_books.push({name: Book.find(book_id).title, count: count})
        end 
        @top_recommended_books = @top_recommended_books.sort_by { |book| book[:count] }.reverse
        @top_recommended_books = @top_recommended_books[0, [@top_recommended_books.size, 5].min]
       
        #rated books
        @rated_books = @feedbacks_record_since_one_year
        @rated_books_rating_avg = @rated_books.group(:book_id).average(:rating)

        @top_rated_books = []
        @rated_books_rating_avg.each do |book_id, rating|
            @top_rated_books.push({name: Book.find(book_id).title, rating: rating.round(2) })
        end 
        @top_rated_books = @top_rated_books.sort_by { |obj| obj[:rating] }.reverse
        @top_rated_books = @top_rated_books[0, [@top_rated_books.size, 5].min]


        @users_record_since_one_year = UserRecord.where("created_at >= ?", 6.months.ago.at_beginning_of_month)
        
        #most checkout users
        @checkout_users = @users_record_since_one_year.where("record_type = #{CHECKOUT_RECORD_TYPE}")
        @checkout_user_record = @checkout_users.group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count
        @checkout_user_record.shift
        @checkout_user_record_exist = false

        @checkout_user_record.each {|key, value| @checkout_user_record_exist =true if value!=0 }
        @top_checkout_users_group = @checkout_users.group(:user_id).count

        @top_checkout_users = []
        @top_checkout_users_group.each { |key,value| 
            @top_checkout_users.push({name: User.find(key).full_name, count: value})
        }
        @top_checkout_users = @top_checkout_users.sort_by {|a| a[:count]}.reverse
        @top_checkout_users = @top_checkout_users[0, [@top_checkout_users.size, 5].min]
        
        # wishlist books
        @wishlist_users = @users_record_since_one_year.where("record_type = #{WISHLIST_RECORD_TYPE}")
        @wishlist_user_record = @wishlist_users.group_by_month(:created_at, format: "%b %y", range: 6.months.ago.at_beginning_of_month..Time.now).count

        @wishlist_user_record.shift
        @wishlist_user_record_exist = false
        @wishlist_user_record.each {|key, value| @wishlist_user_record_exist =true if value!=0 }

        
        @top_wishlist_users_group = @wishlist_users.group(:user_id).count

        @top_wishlist_users = []
        @top_wishlist_users_group.each { |key,value| 
            @top_wishlist_users.push({name: User.find(key).full_name, count: value})
        }
        @top_wishlist_users = @top_wishlist_users.sort_by {|obj| obj[:count]}.reverse
        @top_wishlist_users = @top_wishlist_users[0, [@top_wishlist_users.size, 5].min]
         
        # group checkout book and wishlist book
        @users_data = [{name: 'checout out', data: @checkout_user_record}, {name: 'wishlist', data: @wishlist_user_record}]
    end 

    private 
    def required_admin
        if !current_user.admin
            flash[:alert] = "you can't visit analysis page"
            redirect_to books_path
        end
    end
end