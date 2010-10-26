Feature: walking
    In order to move around
    As a player on the worldmap
    I want to move relative to my current position

Scenario: walk left
    Given I am at 320, 240
    And I press 'Left' for 20 ticks
    When 50 ticks have passed
    Then I should be at 127, 240