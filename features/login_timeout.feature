Feature: Login Timeout
    As a user or admin
    I want my login to time out
    In order to protect my account

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |

    Scenario Outline:
        Given I am signed in as a <role>
        And I have not interacted with my account for 1 hours
        When I try to make a donation
        Then I should be redirected to the login page

        Examples:
            | role |
            | user |
            | admin |