require 'csv'

class User < ApplicationRecord
    has_secure_password
    
    validates :first_name, :last_name, :street_address_line_1, :city, :state, :zip_code, presence: true, on: :user
    validates :zip_code, numericality: { greater_than_or_equal_to: 0, only_integer: true }, on: [:create, :user], unless: lambda{ |user| user.admin? }
    
    validates :email, presence: true, uniqueness: { case_sensitive: true }
    validates_email_format_of :email, message: "Invalid email"
    
    validates :password, confirmation: true, presence: true, on: :create
    validates :password_confirmation, presence: true, on: [:create, :update], unless: lambda{ |user| user.password.blank? }
    
    validates :street_address_line_1, presence: true, if: :street_address_line_2?

    has_many :made_donations

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      UserMailer.forgot_password(self).deliver# This sends an e-mail with a link for the user to reset the password
    end

    def send_donation_confirmation(money)
      UserMailer.donation_confirmation(self, money).deliver
    end
      # This generates a random password reset token for the user
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

    def self.to_csv
      attributes = %w{email name membership}
      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |user|
          csv << attributes.map{ |attr| user.send(attr) }
        end
      end
    end

    def recurring_id(id)
      made_donations.each do |donation|
        return donation.payment_id if donation.payment_id.eql?(id) and donation.recurring
      end
      nil
    end

    def recurring_record(id)
      made_donations.each do |donation|
        return donation if donation.recurring and donation.payment_id.eql?(id)
      end
      nil
    end

    def membership_name
      membership.split(' ^ ')[0]
    end

    def membership_id
      (not membership.eql?("None")) ? membership.split(' ^ ')[1] : nil
    end

    def name
      "#{first_name} #{last_name}"
    end
end
