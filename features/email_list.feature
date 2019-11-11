Feature: Email List
    As an administrator
    I want to get emails for a different user membership lists
    In order to convey information about BVJS
    
    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am signed in as a admin

    # https://www.codementor.io/victor_hazbun/export-records-to-csv-files-ruby-on-rails-vda8323q0
    Scenario:
        When I click 'Get Emails'
        I should 