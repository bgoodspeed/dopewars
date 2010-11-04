Feature: battle
    In order to kill things
    As a player on the worldmap
    I want to start a battle

Scenario: start a fight artificially
    Given I am at 320, 240
    And I start a fight
    When 2 ticks have passed
    Then I should be in a battle

Scenario: complete an artificial fight
    Given I am at 320, 240
    And I start a fight
    And 20 ms have passed
    And I should be in a battle
    And 'hero' should have 1022 battle points
    And 'cohort' should have 1022 battle points
    And 'hero' should have 5 hit points
    And the first monster should have 3 hit points
    And the first monster should have 820 battle points
    When 2 ticks have passed
    Then I should be in a battle

Scenario: start a fight on the world map for real
    Given I am at 320, 240
    And I press 'Down' for 1000 ms
    And 200 ms have passed
    And I press 'Right' for 500 ms
    When 200 ms have passed
    Then I should be in a battle
