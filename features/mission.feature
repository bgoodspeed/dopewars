Feature: missions
    In order to progress through the story
    As a player on the worldmap
    I want to have missions with prereqs, steps and rewards


Scenario: check missions
    Given I press 'Menu'
    And 2 ticks have passed
    And I should be on 'Status'
    And I press 'Down'
    And I press 'Down'
    And I press 'Down'
    And I press 'Down'
    When 2 ticks have passed
    Then I should see the Menu Layer
    And I should be on 'Missions'
