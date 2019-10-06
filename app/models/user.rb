class User < ApplicationRecord
    has_secure_password
    validates :first_name, :last_name, presence: true
    validates :email, presence: true
    validates :password, confirmation: true, presence: true

    validates :street_address_line_1, :city, :state, :zip_code, presence: true, on: :user
    validates :street_address_line_1, presence: true, if: :street_address_line_2?, on: :user
end
