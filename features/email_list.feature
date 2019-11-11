Feature: Email List
    As an administrator
    I want to get emails for a different user membership lists
    In order to convey information about BVJS
    
    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a admin

    # https://www.codementor.io/victor_hazbun/export-records-to-csv-files-ruby-on-rails-vda8323q0
    Scenario:
        When I click 'Get Emails'
        # I have a definition for this on feature/print-receipts branch
        Then I should I should get a response with content-type 'application/csv'


# This is pretty much the only cucumber test you need
# You'll put more detailed functionality tests in rspec
# First, write your RSpec tests
# - need to make sure we can click the button
# - need to make sure we can get the correct subset of users
# - etc.
# Then, create a controller with an index view: rails g EmailLists index
# Add a button on the admin show page that lets us print all emails
# Add some selectors that help an admin choose a subset of all emails
# Then you can start testing against the RSpec and making sure your code does what you wanted it to