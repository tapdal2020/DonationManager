require 'cucumber/rspec/doubles'

Given(/^the following users exist$/) do |table|
    table.hashes.each do |user|
        User.create!(user)
    end
end

Given(/^I am on the home page$/) do 
    visit root_path
end

Given(/^I have clicked "(.*)"$/) do |link|
    click_link link
end

Given(/^I have pressed "(.*)"$/) do |button|
    click_button button
end

Given(/^I am signed in as a (user|admin)$/) do |role|
    visit root_path
    fill_in 'user_email', with: "#{role}@test.com"
    fill_in 'user_password', with: "#{role}"
    click_button 'Log In'
end

Given(/^I am signed in as a (user|admin) with remember me$/) do |role|
    visit root_path
    fill_in 'user_email', with: "#{role}@test.com"
    fill_in 'user_password', with: "#{role}"
    check('user_rememberme')
    click_button 'Log In'
end

Given("I have not interacted with my account for {int} hours") do |int|
    invalid_time = Time.now + int.hours + 2.seconds
    allow(Time).to receive(:now).and_return(invalid_time)
end

Given("paypal will authorize payment of {int} dollars") do |int|
    Rails.application.routes.append do
      get '/cgi-bin/webscr' => "donation_transactions#new"
    end

    payment = PayPal::SDK::REST::Payment.new({
        transaction: {
            currency: "USD",
            items: [{
                name: 'Brazos Valley Jazz Society Donation',
                quantity: 1,
                currency: "USD",
                price: int
              }]
          },
        return_url: 'http://localhost:3000/donation_transactions/new',
        cancel_url: 'http://localhost:3000/donation_transactions/new',
        money: int
    })
    payment.create
    allow(PaypalService).to receive(:create_instant_payment).and_return(payment)
  
    Rails.application.reload_routes!

    stub_request(:post, "https://api.sandbox.paypal.com/v1/oauth2/token").with(
          body: {"grant_type"=>"client_credentials"},
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Basic QVVfRDBFblIxVWhoT1JEdTJGRllMdXJWZC1ydFpZSHpWNFhsTTNzWlF3eFVISFdaR0JQNDVGLXpIaExXZDFmSUYweU1VX3pYWnpCbHUtd3M6RU1lQXhVVjhUenJzSndtWkVyNzhacVNCa3haT3lWcFR3YnNiMWxURGNyUGpuZDRDWWZRU2RhTkdmNWl4TGJuaVFCd09IVkhMRzNibG9JdXc=',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'Paypal-Request-Id'=>payment.request_id,
          'User-Agent'=>'PayPalSDK/PayPal-Ruby-SDK 1.7.3 (paypal-sdk-core 1.7.3; ruby 2.5.5p157-x64-mingw32;OpenSSL 1.1.1b  26 Feb 2019)'
          }).to_return(status: 200, body: "", headers: {})
end

Given "I have made a donation of {int} dollars" do |int|
    Rails.application.routes.append do
        get '/cgi-bin/webscr' => "donation_transactions#new"
    end
  
    payment = PayPal::SDK::REST::Payment.new({
        transaction: {
            currency: "USD",
            items: [{
                name: 'Brazos Valley Jazz Society Donation',
                quantity: 1,
                currency: "USD",
                price: int
            }]
        },
        return_url: 'http://localhost:3000/donation_transactions/new',
        cancel_url: 'http://localhost:3000/donation_transactions/new',
        money: int
    })

    payment.create
    allow(PaypalService).to receive(:create_instant_payment).and_return(payment)

    Rails.application.reload_routes!

    stub_request(:post, "https://api.sandbox.paypal.com/v1/oauth2/token").with(
        body: {"grant_type"=>"client_credentials"},
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>'Basic QVVfRDBFblIxVWhoT1JEdTJGRllMdXJWZC1ydFpZSHpWNFhsTTNzWlF3eFVISFdaR0JQNDVGLXpIaExXZDFmSUYweU1VX3pYWnpCbHUtd3M6RU1lQXhVVjhUenJzSndtWkVyNzhacVNCa3haT3lWcFR3YnNiMWxURGNyUGpuZDRDWWZRU2RhTkdmNWl4TGJuaVFCd09IVkhMRzNibG9JdXc=',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Paypal-Request-Id'=>payment.request_id,
        'User-Agent'=>'PayPalSDK/PayPal-Ruby-SDK 1.7.3 (paypal-sdk-core 1.7.3; ruby 2.5.5p157-x64-mingw32;OpenSSL 1.1.1b  26 Feb 2019)'
        }).to_return(status: 200, body: "", headers: {})

    click_link "Make a Donation"
    fill_in("make_donation_donation_amount", with: 4)
    click_button "Donate"    
end

Given "I have received and followed a password reset link" do
    visit root_path
    click_link "Forgot password?"
    fill_in "email", with: "user@test.com"
    click_button "Reset Password"
    
    token = User.find_by_email("user@test.com").password_reset_token
    visit edit_password_reset_path(token)
end

When(/^I fill in "(.*)" with "(.*)"$/) do |label, entry|
    if label == 'user_state'
        find(:select, label).find(:option, entry).select_option
    else
        fill_in(label, with: entry)
    end
end

When(/^I press "(.*)"$/) do |button|
    click_button button
end

When(/^I click "(.*)"$/) do |link|
    click_link link
end

When (/^I fill in new (user|admin) information$/) do |role|
    entries = { 'user_first_name' => 'FirstName', 'user_last_name' => 'LastName', 'user_email' => 'firstlast@email.com', 'user_password' => 'user', 'user_password_confirmation' => 'user', 'user_street_address_line_1' => 'home', 'user_city' => 'College Station', 'user_zip_code' => '77840' }
    
    check('user_admin') if role == 'admin'
    find(:select, 'user_state').find(:option, 'TX').select_option

    entries.each do |item, value|
        fill_in item, with: value
    end
end

When (/^I fill in update user information$/) do 
    entries = { 'user_first_name' => 'FirstName', 'user_last_name' => 'LastName', 'user_email' => 'firstlast@email.com', 'user_street_address_line_1' => 'home', 'user_city' => 'College Station', 'user_zip_code' => '77840' }
    
    find(:select, 'user_state').find(:option, 'AZ').select_option

    entries.each do |item, value|
        fill_in item, with: value
    end
end

When(/^I fill in new user information missing (.*)?$/) do |item|
    entries = { 'user_first_name' => 'FirstName', 'user_last_name' => 'LastName', 'user_email' => 'firstlast@email.com', 'user_password' => 'user', 'user_password_confirmation' => 'user', 'user_street_address_line_1' => 'home', 'user_city' => 'College Station', 'user_zip_code' => '77840' }

    unless item.nil?
        entries[item] = nil unless item == 'user_state'
    end
    
    find(:select, 'user_state').find(:option, 'TX').select_option unless item == 'user_state'

    entries.each do |item, value|
        fill_in item, with: value
    end
end

When(/^I try to make a donation$/) do
    click_link 'Make a Donation'
    allow(Time).to receive(:now).and_call_original
end

When(/^I check "(.*)"$/) do |item|
    check(item)
end

When(/^I uncheck "(.*)"$/) do |item|
    uncheck(item)
end

Then(/^I should see "(.*)"$/) do |item|
    expect(page).to have_content(item)
end

Then(/^I should see "(.*)" button$/) do |button|
    expect(page).to have_selector(:link_or_button, button)
end

Then(/^the login should fail$/) do
    expect(page).to have_content('Invalid email or password')
end

Then(/^I should be redirected to the (.*) page$/) do |role|
    if role == 'user'
        expect(page).to have_content('Donations Overview')
    elsif role == 'admin'
        expect(page).to have_content('Donation Administrator')
    elsif role == 'login'
        expect(page).to have_content('BVJS Donor Portal')
    elsif role == 'donations'
        expect(page).to have_content("Donate to\nBrazos Valley Jazz Society")
    end
end

Then(/^I should get a response with content-type "(.*)"$/) do |content_type|
    expect(page.response_headers['Content-Type']).to eq(content_type)
end