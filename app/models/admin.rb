class Admin < ApplicationRecord
    has_secure_password
    validates :email, presence: true, uniqueness: { case_sensitive: true }
    validates :password, confirmation: true, presence: true
end
