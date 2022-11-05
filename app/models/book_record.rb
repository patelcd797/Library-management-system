class BookRecord < ApplicationRecord
    has_one :book
    validates :record_type, presence: true
end