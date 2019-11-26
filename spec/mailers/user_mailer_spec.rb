require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
    fixtures :users

    it 'should assign user and greeting with forgot password' do
        mail = described_class.forgot_password users(:one)
        allow(Rails.application).to receive_message_chain(:routes, :url_helpers, :edit_password_reset_url) { 'rails_is_awesome' }
        allow_any_instance_of(User).to receive(:password_reset_token).and_return(0)

        expect(mail.deliver_now.to).to eq([users(:one).email])
    end

    it 'should assign user and money with donation confirmation' do
        mail = described_class.donation_confirmation users(:one), "4"

        expect(mail.deliver_now.to).to eq([users(:one).email])
    end
end