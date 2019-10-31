Feature: Admin View Donations
    As an administrator
    I want to view all donations
    In order to manage BVJS resources

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a admin

    Scenario Outline:
        Then I should see "<header>"

        Examples:
            | header |
            | Timestamp |
            | Donated Amount |
            | Paypal Transaction ID |
            | Paypal Payer ID |


