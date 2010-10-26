Feature: battle
    In order to kill things
    As a player on the worldmap
    I want to start a battle

Scenario: start a fight
    Given I am at 320, 240
    And I press 'Down' for 46 ticks
    And 70 ticks have passed
    And I press 'Right' for 20 ticks
    When 70 ticks have passed
    Then I should be in a battle
