class MadeDonation < ApplicationRecord
    validates :donor_email, presence: true, on: :user
    validates :payment_id, presence: true, uniqueness: { case_sensitive: true }
    validates :price, presence: true, :numericality { greater_than: 0.00, only_integer: false }
end
