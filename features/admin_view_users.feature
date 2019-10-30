Feature: Admin View Users
    As an admin
    I want to see all users or admins
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
        Given I have not interacted with my account for 1 hours
        When I press "View Users"
        Then I should be redirected to the login page