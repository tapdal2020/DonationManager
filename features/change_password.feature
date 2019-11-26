Feature: Change Password
    As a user
    I want to change my password
    In order to keep my account secure

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a user
        And I have clicked "Edit Profile"

    Scenario Outline:
        When I press "Change Password"
        And I fill in "user_old_password" with "<old>"
        And I fill in "user_password" with "<new>"
        And I fill in "user_password_confirmation" with "<new_conf>"
        And I press "Confirm"
        Then I should see "<expect>"

        Examples:
            | old | new | new_conf | expect |
            | user | better_password123 | better_password123 | Donations Overview |
            | wrong | better_password123 | better_password123 | Change Password |
            | user | better_password123 | wrong_conf | Change Password |
            | user | wrong_conf | better_password123 | Change Password |