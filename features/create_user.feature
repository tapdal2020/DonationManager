Feature: Create User
    As a new user
    I want to create an account
    In order to support BVJS

    Background:
        Given I am on the home page

    Scenario:
        Then I should see "Register"
    
    Scenario:
        When I click "Register"
        Then I should see "Create New User"

    Scenario:
        Given I have clicked "Register"
        When I fill in new user information
        And I press "Save"
        Then I should see "Account Login"

    Scenario Outline:
        Given I have clicked "Register"
        When I fill in new user information missing <item>
        And I press "Save"
        Then I should see "<expect>"

        Examples:
            | item                          |  expect |
            | user_first_name               |  First name can't be blank |
            | user_last_name                |  Last name can't be blank |
            | user_email                    |  Email can't be blank |
            | user_password                 |  Password can't be blank |
            | user_password_confirmation    |  Password confirmation doesn't match Password |
            | user_street_address_line_1    |  Street address line 1 can't be blank |
            | user_city                     |  City can't be blank |
            | user_state                    |  State can't be blank |
            | user_zip_code                 |  Zip code can't be blank |