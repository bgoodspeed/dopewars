Feature: menu
    In order to use items, see stats, etc
    As a player on the worldmap
    I want to load a menu

Scenario: opening menu
    Given I am at 320, 240
    And I press 'Menu'
    When 2 ticks have passed
    Then I should see the Menu Layer

Scenario: closing menu
    Given I am at 320, 240
    And I press 'Menu'
    And I press 'Menu'
    When 2 ticks have passed
    Then I should not see the Menu Layer