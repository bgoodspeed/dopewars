Feature: battle
    In order to kill things
    As a player on the worldmap
    I want to start a battle

Scenario: start a fight artificially
    Given I am at 320, 240
    And I start a fight
    When 2 ticks have passed
    Then I should be in a battle

Scenario: start a fight on the world map for real
    Given I am at 320, 240
    And I press 'Down' for 48 ticks
    And 70 ticks have passed
    And I press 'Right' for 20 ticks
    When 70 ticks have passed
    Then I should be in a battle
