class Book < ApplicationRecord
    validates :title, presence: true, uniqueness: true, length: { minimum: 2, maximum: 20}
    validates :description, presence: true, length: { minimum: 5, maximum: 100}
    validates :author, presence: true, length: { minimum:2, maximum: 20}
    validates :language, presence: true
    validates :price, presence: true
    has_one_attached :image, :dependent => :destroy

    def self.search(param)
        result = (matches_by_title(param) + matches_by_description(param) + matches_by_author(param)).uniq
        result 
    end

    def self.matches_by_title(param)
        matches("title", param)
    end
    def self.matches_by_description(param)
        matches("description", param)
    end
    def self.matches_by_author(param)
        matches("author", param)
    end
    def self.matches(field, param)
        where("#{field} like ?", "%#{param}%")
    end
end