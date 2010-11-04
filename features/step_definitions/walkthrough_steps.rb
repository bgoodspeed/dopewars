require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'
require 'spec/rspec_helper'

called = 0
Given /^I am at (\d+), (\d+)$/ do |x, y|
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

Given /^I press '(\w+)' for (\d+) ms$/ do |key, ms|
  @g.set_key_pressed_for_time(switch_key(key), ms.to_i)
end


When /^(\d+) ticks have passed$/ do |arg1|
  @g.step_until(arg1.to_i)
end

Given /^(\d+) ms have passed$/ do |arg1|
  @g.step_until_time(arg1.to_i)
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

Given /^I should be on 'All Items'$/ do
  @g.current_selected_menu_entry_name.should == "All Items"
end


Then /^I should be on '(\w+\.*\w*)'$/ do |arg1|
  @g.current_selected_menu_entry_name.should == arg1
end

include UtilityMatchers
Then /^the current menu shows '(\w+)'$/ do |what|
  @g.current_menu_entries.should contain? what
end

Given /^I press '(\w+)' (\d+) times$/ do |what, how_many|
  how_many.to_i.times {
    press(what)
    @g.step_until(1)
  }
end



Then /^I should be on 'Slot (\d+)'$/ do |arg1|
  @g.current_selected_menu_entry_name.should == "Slot #{arg1}"
end

Then /^I should be on 'Upgrade yourself'$/ do
  @g.current_selected_menu_entry_name.should == 'Upgrade yourself'
end

Given /^I start a fight$/ do
  monster = MonsterFactory.new.make_monster(@g.player, @g.universe)
  @g.start_battle(monster)
end

Given /^'(\w+)' should have (\d+) battle points$/ do |hero_name, battle_points|
  @g.current_battle.hero_by_name(hero_name).readiness_points.should == battle_points.to_i
end

Given /^'(\w+)' should have (\d+) hit points$/ do |hero_name, hit_points|
  @g.current_battle.hero_by_name(hero_name).current_hp.should == hit_points.to_i
end

Given /^the first monster should have (\d+) hit points$/ do |hp|
  @g.current_battle.first_monster.current_hp.should == hp.to_i
end

Given /^the first monster should have (\d+) battle points$/ do |bp|
  @g.current_battle.first_monster.readiness_points.should == bp.to_i
end
