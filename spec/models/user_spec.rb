require "validates_email_format_of/rspec_matcher"
        
describe User do
    it { should validate_email_format_of(:email).with_message('Invalid email') }
    it 'should return a csv' do
        csv = User.to_csv
        expect(csv.include? 'email,name,membership').to be(true)
    end
end