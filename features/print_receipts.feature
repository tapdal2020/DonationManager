Feature: Print Receipts
    As a user
    I want to print receipts from my 
    In order to file my tax returns

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a user
    
    Scenario:
        Then I should see "Print All Receipts" button

    Scenario:
        When I press "Print All Receipts"
        Then I should get a response with content-type "application/pdf"