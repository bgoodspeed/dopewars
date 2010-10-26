Feature: treasure
    In order to accumulate junk
    As a player on the worldmap
    I want to open treasure boxes

Scenario: open a treasure box
    Given I am at 320, 240
    And I press 'Up' for 15 ticks
    And 40 ticks have passed
    And I press 'Left' for 45 ticks
    And 70 ticks have passed
    And I press 'Up' for 1 ticks
    And 5 ticks have passed
    When I press 'Interact' and wait 15 ticks
    Then I should have a notification
    And I should have 1 more items
