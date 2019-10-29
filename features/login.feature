Feature: Login
    As a user or administrator
    I want to login to the system
    In order to manage my account

    Background:
        Given I am on the home page
        And the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |

    Scenario:
        Then I should see "Log In"
        And I should see "Email address:"
        And I should see "Password:"
        And I should see "Log In" button

    Scenario Outline:
        When I fill in "user_email" with "<email>"
        And I fill in "user_password" with "<password>"
        And I press "Log In"
        Then I should see "<result>"

        Examples:
            | type  | email             | password  | result                    |
            | user  | user@test.com       | user      | Donations Overview        |
            | admin | admin@test.com    | admin      | Donation Administrator    |

    Scenario:
        When I fill in "user_email" with "non_existent@email.com"
        And I fill in "user_password" with "bad_password"
        And I press "Log In"
        Then the login should fail

    Scenario Outline:
        Given I am signed in as a <role>
        When I am on the home page
        Then I should be redirected to the <role> page

        Examples:
            | role |
            | user |
            | admin |

