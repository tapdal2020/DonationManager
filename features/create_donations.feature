Feature: Create Donations
    As a user
    I want to create a donation
    In order to support BVJS

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a user

    Scenario:
        When I click "Make a Donation"
        Then I should see "Home" button
        And I should see "Donate" button
        And I should see "Donation Amount:"

    Scenario:
        Given paypal will authorize payment of 4 dollars
        When I click "Make a Donation"
        And I fill in "make_donation_donation_amount" with "4"
        And I press "Donate"
        # Do this because WebMock or Paypal SDK clear session (???)
        And I fill in "user_email" with "user@test.com"
        And I fill in "user_password" with "user"
        And I press "Log In"
        # Now we're back to it
        Then I should see "$4.00"
