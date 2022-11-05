class UserRecord < ApplicationRecord
    has_one :user
    validates :record_type, presence: true
end