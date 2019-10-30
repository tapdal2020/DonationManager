Feature: Admin Create New Admin
    As an admin
    I want to create a new admin
    In order to help manage the system

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a admin

    Scenario Outline:
        When I press "Create New User"
        Then I should see "Create New User"
        And I should see "Admin?"
        When I fill in new admin information
        And I press "Save"
        Then I should see "Donation Administrator"