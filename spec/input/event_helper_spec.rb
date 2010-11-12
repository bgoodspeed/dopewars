
require 'spec/rspec_helper'

describe EventHelper do
  include DomainMocks

  before(:each) do
    @game = mock_game

    expect_constructor_hooks
    @event_helper = EventHelper.new(@game, [:always, :on, :hooks], [:menu, :killed], [:menulayer, :active], [:battle], [:battle_layer], [:player], [:npc1, :npc2])
  end

  def expect_hook_appended(g, what)
    g.should_receive(:append_hook).with(what).and_return what
  end
  def expect_hook_removed(g, what)
    g.should_receive(:remove_hook).with(what).and_return what
  end

  def expect_constructor_hooks
    expect_hook_appended(@game, :always)
    expect_hook_appended(@game, :on)
    expect_hook_appended(@game, :hooks)
    expect_hook_appended(@game, :menu)
    expect_hook_appended(@game, :killed)
    expect_hook_appended(@game, :menulayer)
    expect_hook_appended(@game, :active)
    expect_hook_appended(@game, :battle)
    expect_hook_appended(@game, :battle_layer)
    expect_hook_appended(@game, :player)
    expect_hook_appended(@game, :npc1)
    expect_hook_appended(@game, :npc2)

    expect_hook_removed(@game, :menulayer)
    expect_hook_removed(@game, :active)
    expect_hook_removed(@game, :battle)

  end

  it "should bind hooks" do
    @event_helper.always_on_hooks.size.should == 3
  end

  it "should define non menu hooks" do
    @event_helper.non_menu_hooks.size.should == 5
  end

  

end
