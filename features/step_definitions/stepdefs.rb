require 'cucumber/rspec/doubles'

Given(/^the following users exist$/) do |table|
    table.hashes.each do |user|
        User.create(user)
    end
end

Given(/^I am on the home page$/) do 
    visit root_path
end

Given(/^I have clicked "(.*)"$/) do |link|
    click_link link
end

Given(/^I am signed in$/) do
    visit root_path
    fill_in 'user_email', with: 'me@user.com'
    fill_in 'user_password', with: 'user'
    click_button 'Log In'
end

When(/^I fill in "(.*)" with "(.*)"$/) do |label, entry|
    fill_in(label, with: entry)
end

When(/^I press "(.*)"$/) do |button|
    click_button button
end

When(/^I click "(.*)"$/) do |link|
    click_link link
end

When (/^I fill in new user information$/) do
    entries = { 'user_first_name' => 'FirstName', 'user_last_name' => 'LastName', 'user_email' => 'firstlast@email.com', 'user_password' => 'user', 'user_password_confirmation' => 'user', 'user_street_address_line_1' => 'home', 'user_city' => 'College Station', 'user_state' => 'TX', 'user_zip_code' => '77840' }
    entries.each do |item, value|
        fill_in item, with: value
    end
end

When(/^I fill in new user information missing (.*)?$/) do |item|
    entries = { 'user_first_name' => 'FirstName', 'user_last_name' => 'LastName', 'user_email' => 'firstlast@email.com', 'user_password' => 'user', 'user_password_confirmation' => 'user', 'user_street_address_line_1' => 'home', 'user_city' => 'College Station', 'user_state' => 'TX', 'user_zip_code' => '77840' }

    unless item.nil?
        entries[item] = nil
    end

    entries.each do |item, value|
        fill_in item, with: value
    end
end

When("I try to perform an action but have not interacted with my account for {int} hours") do |int|
    invalid_time = Time.now + int.hours + 2.seconds
    allow(Time).to receive(:now).and_return(invalid_time)
end

Then(/^I should be redirected to the login page$/) do
    click_button 'Make a Donation'
    allow(Time).to receive(:now).and_call_original

    expect(page).to have_content('Log In')
end

Then(/^I should see "(.*)"$/) do |item|
    expect(page).to have_content(item)
end

Then(/^I should see "(.*)" button$/) do |button|
    expect(page).to have_selector(:link_or_button, button)
end

Then(/^the login should fail$/) do
    expect(page).to have_content('Email or password invalid')
end

Then(/^I should be redirected to the user page$/) do
    expect(page).to have_content('Donations Overview')
end