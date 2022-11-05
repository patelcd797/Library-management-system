class Feedback < ApplicationRecord
    has_one :book

    validates :comment, presence: true, length: { minimum: 2 }
    validates :rating, presence: true

end