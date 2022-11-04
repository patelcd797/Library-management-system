class User < ApplicationRecord
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, 
                    length: { maximum: 125}, 
                    uniqueness: true,
                    format: {with: VALID_EMAIL_REGEX}
    validates :last_name, presence: true
    validates :contact_number, presence: true, uniqueness: true, length: {minimum: 10, maximum: 12}
    has_secure_password
    has_one_attached :image, :dependent => :destroy
    validates :image, presence: true

    has_many :checkout_book
    has_many :books, through: :checkout_book

    has_many :reserve_book, :dependent => :destroy
    has_many :reserve_books, through: :reserve_book, source: :book

    def full_name
        return "#{first_name} #{last_name}" if self.first_name || self.last_name
        "Anonymous"
    end

    def self.search(param)
        param.strip!
        users = matches("email", param) + matches("contact_number", param)
        return users.first if users.size 
        nil
    end

    def self.matches(field, param)
        where("#{field} like?", param)
    end

    def book_reserved?(book)
        reserve_books.include?(book)
    end

    def self.search_user(param)
        if param
            result = where("email like ? OR first_name like ? OR last_name like ? OR contact_number like ?", "%#{param}%","%#{param}%","%#{param}%", "%#{param}%")
            result if result.size > 0
            all
        else
            scoped
        end
    end
end