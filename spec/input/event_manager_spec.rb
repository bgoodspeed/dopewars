# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe EventManager do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @event_manager = EventManager.new
  end

  def expect_hook_swap(game, off_hooks, on_hooks)
    off_hooks.each {|h| game.should_receive(:remove_hook).with(h) }
    on_hooks.each {|h| game.should_receive(:append_hook).with(h) }
  end

  it "turns event hooks on" do
    expect_hook_swap(@game, [:x, :y], [:alpha, :beta])
    @event_manager.swap_event_sets(@game, true, [:alpha, :beta], [:x, :y])
  end

  it "turns event hooks off" do
    expect_hook_swap(@game, [:alpha, :beta], [:x, :y])
    @event_manager.swap_event_sets(@game, false, [:alpha, :beta], [:x, :y])
  end
end

