Feature: Membership Tiers
    As a user
    I want to use a subscribe as a member to a tiered system
    In order to create a recurring donation to BVJS

    Background:
        Given the following users exist
            | first_name | last_name | email | password | password_confirmation | street_address_line_1 | city | state | zip_code | admin |
            | user | test | user@test.com | user | user | home | austin | tx | 78726 | false |
            | admin | test | admin@test.com | admin | admin | home | austin | tx | 78726 | true |
        And I am on the home page

    Scenario Outline:
        When I click "Register"
        Then I should see "Membership Type"
        And I should see "<item>"

        Examples:
            | item |
            | None |
            | Low |
            | Middle |
            | High |

    Scenario:
        Given I am logged in as a user
        And I am a member
        Then I should see "Edit Membership"

    Scenario:
        Given I am logged in as a user
        And I am not a member
        Then I should see "Subscribe"

    Scenario Outline:
        Given I am logged in as a user
        And I am not a member
        When I press "Subscribe"
        Then I should see "Membership Type"
        And I should see "<item>"
        And I should see "Save" button

        Examples:
            | item |
            | None |
            | Low |
            | Middle |
            | High |

    Scenario Outline:
        Given I am logged in as a user
        And I am a member
        When I press "Edit Membership"
        Then I should see "Current Membership: "
        And I should see "<item>"
        And I should see "Save" button

        Examples:
            | item |
            | None |
            | Low |
            | Middle |
            | High |

    Scenario Outline:
        Given I am logged in as a user
        And I am <qualifier> a member
        When I press "<button>"
        And I select "Low"
        And I press "Save"
        Then I should be redirected to PayPal

        Examples:
            | qualifier | button |
            |  not | Subscribe |
            | | Edit Membership |
    