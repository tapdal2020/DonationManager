Feature: User CRUD User
    As a User
    I want to edit my information
    In order to keep my account up to date

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a user

    Scenario:
        When I press "Edit Profile"
        Then I should see "Edit Profile"
        When I fill in update user information
        And I press "Save"
        Then I should see "Donations Overview"