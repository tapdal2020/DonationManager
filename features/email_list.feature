Feature: Email List
    As an administrator
    I want to get emails for a different user membership lists
    In order to convey information about BVJS
    
    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin | membership |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false | high |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true | |
        And I am signed in as a admin

    Scenario:
        When I click "Get Emails"
        Then I should see "User Emails"
        And I should see "Membership Type"
        And I should see "Generate" button

    Scenario:
        When I click "Get Emails"
        And I press "Generate"
        Then I should see "Email,Name,Membership"
        And I should see "high"

    Scenario:
        When I click "Get Emails"
        And I press "Back"
        Then I should see "Donation Administrator"