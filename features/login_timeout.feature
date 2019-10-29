Feature: Login Timeout
    As a user or admin
    I want my login to time out
    In order to protect my account

    Background:
        Given I am signed in

    Scenario:
        When I try to perform an action but have not interacted with my account for 1 hours
        Then I should be redirected to the login page