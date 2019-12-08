Feature: Password Reset
    As a user
    I want to reset my password
    In order to access my account if I forgot my password

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am on the home page

    Scenario Outline:
        Given I have clicked "Forgot password?"
        Then I should see "<item>"

        Examples:
            | item |
            | Reset Password |
            | Email |
    
    Scenario:
        Given I have clicked "Forgot password?"
        Then I should see "Reset Password" button

    Scenario:
        Given I have clicked "Forgot password?"
        When I fill in "email" with "user@test.com"
        And I press "Reset Password"
        Then I should see "E-mail sent with password reset instructions."
        And I should see "BVJS Donor Portal"

    Scenario Outline:
        Given I have received and followed a password reset link
        Then I should see "<item>"

        Examples:
            | item |
            | Reset Password |
            | New Password |
            | Confirm Password |

    Scenario:
        Given I have received and followed a password reset link
        Then I should see "Update password" button

    Scenario Outline:
        Given I have received and followed a password reset link
        When I fill in "user_password" with "newpass"
        And I fill in "user_password_confirmation" with "<confirm>"
        And I press "Update password"
        Then I should see "<result>"

        Examples:
            | confirm | result |
            | newpass | BVJS Donor Portal |
            | wrong | Reset Password |


