class MadeDonation < ApplicationRecord
    validates :user_id, presence: true, on: :user
    validates :payment_id, presence: true, uniqueness: { case_sensitive: true }
    validates :price, presence: true, default: nil, numericality: { greater_than: 0.00, only_integer: false }, unless: lambda{ |made_donation| made_donation.price.nil? }
    validates :token, presence: false, uniqueness: { case_sensitive: true }
    validates :payer_id, presence: false

    belongs_to :user

    def self.monthly_donations
      group_by_month(:created_at, last: 12).sum(:price)
    end
end
