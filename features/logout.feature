Feature: Logout
    As a user or admin
    I want to logout
    In order to protect my account

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true | 
    
    Scenario Outline:
        Given I am signed in as a <role>
        When I click "Logout"
        Then I should see "Account Login"

        Examples:
            | role |
            | user |
            | admin |

