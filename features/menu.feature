Feature: menu
    In order to use items, see stats, etc
    As a player on the worldmap
    I want to load a menu

Scenario: navigating submenu
    Given I press 'Menu'
    And 2 ticks have passed
    And I should be on 'Status'
    And I press 'Right'
    When 2 ticks have passed
    And I press 'Down'
    When 2 ticks have passed
    Then I should see the Menu Layer
    And I should be on 'cohort'
    And the current menu shows 'hero'
    And the current menu shows 'cohort'



Scenario Outline: navigating menu
    Given I press 'Menu'
    And 2 ticks have passed
    And I should be on 'Status'
    And I press '<button>'
    When 2 ticks have passed
    Then I should see the Menu Layer
    And I should be on '<active_menu_entry>'
    And the current menu shows 'Status'
    And the current menu shows 'Inventory'
    And the current menu shows 'Levelup'
    And the current menu shows 'Equip'
    And the current menu shows 'Save'
    And the current menu shows 'Load'
Examples:
    | button | active_menu_entry |
    | Up     | Load              |
    | Down   | Inventory         |




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


