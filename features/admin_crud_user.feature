Feature: Admin CRUD Users
    As an admin
    I want to create, read, update, or destroy a user or admin
    In order to manage BVJS users

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a admin

    Scenario Outline:
        When I press "View Users"
        Then I should see "<header>"
        And I should see "EDIT" button

        Examples:
            | header |
            | First Name |
            | Last Name |
            | Email |
            | Admin? |

    Scenario:
        When I press "Create New User"
        Then I should see "Create New User"
        And I should see "Admin?"
        When I fill in new user information
        And I press "Save"
        Then I should see "Donation Administrator"

    Scenario Outline:
        When I press "View Users"
        And I press "EDIT_0"
        Then I should see "<label>"

        Examples:
            | label |
            | First name: |
            | Last name: |
            | Email address: |
            | Street Address: |
            | City: |
            | State: |
            | Zip Code: |
            | Admin? | 

    Scenario Outline:
        When I press "View Users"
        And I press "EDIT_1"
        And I fill in "<field>" with "<value>"
        And I press "Save"
        Then I should see "All Users"
    
        Examples:
            | field | value |
            | user_first_name | NewName |
            | user_last_name | NewName |
            | user_email | newemail@test.com |
            | user_street_address_line_1 | NewHome |
            | user_street_address_line_2 | Apt. 0 |
            | user_city | New Austin |
            | user_state | LA |
            | user_zip_code | 77101 |

    Scenario:
        When I press "View Users"
        And I press "EDIT_1"
        And I check "user_admin"
        And I press "Save"
        Then I should see "All Users"
        When I press "EDIT_1"
        And I uncheck "user_admin"
        And I press "Save"
        Then I should see "All Users"

    Scenario:
        When I press "View Users"
        And I press "EDIT_1"
        And I press "DELETE"
        Then I should see "All Users"