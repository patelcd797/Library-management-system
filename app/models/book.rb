class Book < ApplicationRecord
    validates :title, presence: true, uniqueness: true, length: { minimum: 2, maximum: 20}
    validates :description, presence: true, length: { minimum: 5, maximum: 100}
    validates :author, presence: true, length: { minimum:2, maximum: 20}
    validates :language, presence: true
    validates :price, presence: true
    has_one_attached :image, :dependent => :destroy
    validates :image, presence: true

    has_many :checkout_book
    has_many :users, through: :checkout_book

    has_many :reserve_book, :dependent => :destroy
    has_many :wishlisted_users, through: :reserve_book, source: :user

    def self.search(param)
        if param
            result = where("title like ? OR description like ? OR author like ?", "%#{param}%","%#{param}%","%#{param}%")
            result
        else
            scoped
        end
    end
end