Feature: menu
    In order to use items, see stats, etc
    As a player on the worldmap
    I want to use items


Scenario: using items from inventory
    Given I press 'Menu'
    And 2 ticks have passed
    And I should be on 'Status'
    And I press 'Down'
    And 2 ticks have passed
    And I should be on 'Items'
    And I press 'Right'
    And 2 ticks have passed
    And I should be on 'All Items'
    And I press 'Right'
    And 2 ticks have passed
    And I press 'Right'
    And 2 ticks have passed
    And I should be on 'hero'
    And I press 'Right'
    When 2 ticks have passed
    Then I should see the Menu Layer
    And I should be on 'hero'
