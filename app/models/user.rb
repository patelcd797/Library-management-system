class User < ApplicationRecord
    VALID_EMAIL_REGEX = VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, 
                    length: { maximum: 25}, 
                    uniqueness: true,
                    format: {with: VALID_EMAIL_REGEX}
    validates :last_name, presence: true
    validates :contact_number, presence: true, uniqueness: true, length: {minimum: 10, maximum: 12}
    has_secure_password

    has_many :checkout_book
    has_many :books, through: :checkout_book

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
end