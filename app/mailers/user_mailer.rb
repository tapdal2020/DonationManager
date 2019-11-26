class UserMailer < ApplicationMailer

    def forgot_password(user)
      @user = user
      @greeting = "Hi"
        
      mail to: @user.email, :subject => 'Reset password instructions'
    end

    def donation_confirmation(user,money)
      @user = user
      @money = money

      mail to: @user.email, :subject => 'BVJS Donation Confirmation'
    end

end
  