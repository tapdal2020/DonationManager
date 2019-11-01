class MadeDonation < ApplicationRecord
    validates :user_id, presence: true, on: :user
    validates :payment_id, presence: true, uniqueness: { case_sensitive: true }
    validates :price, presence: true, numericality: { greater_than: 0.00, only_integer: false }
    validates :token, presence: false, uniqueness: true
    validates :payer_id, presence: false

    belongs_to :user
    def self.monthly_donations
        group_by_month(:created_at, last: 12)
        .sum(:price)
      end
end
