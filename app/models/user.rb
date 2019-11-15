require 'csv'

class User < ApplicationRecord
    has_secure_password
    
    validates :first_name, :last_name, :street_address_line_1, :city, :state, :zip_code, presence: true, on: :user
    validates_numericality_of :zip_code, on: [:create, :update], unless: lambda{ |user| user.admin? }, greater_than_or_equal_to: 0, only_integer: true
    
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

    def name
      "#{first_name} #{last_name}"
    end
end
