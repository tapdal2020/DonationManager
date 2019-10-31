Feature: My Donations
    As a user
    I want to see my past donations
    In order to monitor my contributions

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a user

    Scenario Outline:
        Then I should see "<header>"

        Examples:
            | header |
            | Timestamp |
            | Donated Amount |
            | Paypal Transaction ID |
            | Paypal Payer ID |