Feature: Login
    As a user or administrator
    I want to login to the system
    In order to manage my account

    Background:
        Given I am on the home page

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
            | user  | me@user.com       | user      | Donations Overview        |
            | admin | root@admin.com    | root      | Donation Administrator    |

    Scenario:
        When I fill in "user_email" with "non_existent@email.com"
        And I fill in "user_password" with "bad_password"
        And I press "Log In"
        Then the login should fail

    Scenario:
        Given I am signed in
        When I am on the home page
        Then I should be redirected to the user page
