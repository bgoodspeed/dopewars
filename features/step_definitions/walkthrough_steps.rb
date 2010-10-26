require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'
require 'spec/rspec_helper'

called = 0
Given /^I am at (\d+), (\d+)$/ do |x, y|
  @g = Game.new

  @g.set_player_position(x.to_i,y.to_i)
  @original_item_count = @g.inventory_count
end


def switch_key(k)
  conv = { 'Left' => :left, 'Down' => :down, 'Right' => :right, 'Up' => :up}

  rv = conv[k]
  raise "Conversion not setup for #{k}" unless rv
  rv
end

Given /^I press '(\w+)' for (\d+) ticks$/ do |key, ticks|
  @g.set_key_pressed_for(switch_key(key), ticks.to_i)
end

When /^(\d+) ticks have passed$/ do |arg1|
  @g.step_until(arg1.to_i)
end


include WorldMapMatchers

Then /^I should be at (\d+), (\d+)$/ do |arg1, arg2|
  @g.get_player_position.should be_near_enough_to [arg1.to_i, arg2.to_i]
end


def press(what)
  if what =~ /Menu/
    @g.toggle_menu
  elsif what =~ /Interact/
    @g.interact_with_facing(nil)
  else
    @g.simulate_event_with_key(switch_key(what))
  end

end
Given /^I press '(\w+)'$/ do |what|
  press(what)
end

When /^I press '(\w+)' and wait (\d+) ticks$/ do |what, how_long|
  press(what)
  @g.step_until(how_long.to_i)
  
end

Then /^I should see the Menu Layer$/ do
  @g.menu_layer.active?.should be_true
end
Then /^I should not see the Menu Layer$/ do
  @g.menu_layer.active?.should be_false
end

Then /^I should be in a battle$/ do
  @g.battle_layer.active?.should be_true
end


Then /^I should be in world (\d+)$/ do |world_number|
  @g.world_number.should == (world_number.to_i - 1)
end

Then /^I should have a notification$/ do
  @g.notifications_layer.active?.should be_true
  @g.notifications.size.should == 1
end

Then /^I should have (\d+) more items$/ do |arg1|
  @g.inventory_count.should == arg1.to_i + @original_item_count
end



Then /^I should be on (\w+)$/ do |arg1|
  @g.current_selected_menu_entry_name.should == arg1
end

include UtilityMatchers
Then /^the current menu shows '(\w+)'$/ do |what|
  @g.current_menu_entries.should contain? what
end

