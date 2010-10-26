Feature: warp point
    In order to kill things
    As a player on the worldmap
    I want to warp to another world

Scenario: walk and warp
    Given I am at 320, 240
    And I press 'Down' for 80 ticks
    And 110 ticks have passed
    And I press 'Right' for 100 ticks
    And 115 ticks have passed
    And I press 'Up' for 2 ticks
    And 5 ticks have passed
    When I press 'Interact' and wait 80 ticks
    Then I should be in world 2
    
