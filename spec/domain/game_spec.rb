
require 'spec/rspec_helper'

describe Game do
  include DomainMocks
  include DelegationMatchers
  before(:each) do
    @factory = mock_game_internals_factory
    @trigger_factory = mock_trigger_factory
    @game = Game.new(@factory, @trigger_factory)
  end

  it "should be able to quit" do
    catch(:quit) do
      @game.quit
      fail "should have thrown :quit"
    end
  end

  it "should be able to step" do
    @game.step_until(1)
  end
  it "should be able to step with time" do
    expect_lifetime_sequence(@game.event_system)
    @game.step_until_time(300)
  end

  it "should delegate battle layer movement -- up" do
    expect_enter_current_cursor_location(@game.battle_layer)
    @game.battle_up
  end
  it "should delegate battle layer movement -- confirm" do
    expect_enter_current_cursor_location(@game.battle_layer)
    @game.battle_confirm
  end
  it "should delegate menu layer movement -- enter" do
    expect_enter_current_cursor_location(@game.menu_layer)
    @game.menu_enter(nil)
  end
  it "should delegate menu layer movement -- right" do
    expect_enter_current_cursor_location(@game.menu_layer)
    @game.menu_right(nil)
  end

  it "should be able to capture screenshots" do
    #TODO this does not actually work
    @game.capture_ss(nil)
  end

  it "should be able to process events" do
    stub_queue_with_events(@game.event_system)
    expect_event_handled(@game.event_handler)
    @game.process_events
  end

  it "should draw weapon if player is using it" do
    stub_using_weapon(@game.player)
    expect_draw_weapon(@game.player)
    @game.blit_player
  end

  it "should simulate events" do
    expect_event_added(@game.event_system.queue)
    @game.simulate_event_with_key(:keysym)
  end

  it "should interact with facing" do
    expect_interact_with_facing(@game.player, @game)
    @game.interact_with_facing(nil)
  end

  it "should allow toggling of menu" do
    stub_menu_layer_active(@game.menu_layer)
    expect_swap_event_sets(@game.event_manager, @game, true)
    expect_toggle_activity(@game.menu_layer)
    @game.toggle_menu
  end
  it "should allow toggling of menu when already active" do
    stub_menu_layer_active(@game.menu_layer, false)
    expect_swap_event_sets(@game.event_manager, @game, false)
    expect_toggle_activity(@game.menu_layer)
    expect_reset_indices(@game.menu_layer)
    @game.toggle_menu
  end

  it "should toggle battle hooks when active" do
    expect_swap_event_sets(@game.event_manager, @game, true)
    @game.toggle_battle_hooks(true)
  end
  it "should toggle battle hooks when inactive" do
    expect_swap_event_sets(@game.event_manager, @game, false)
    @game.toggle_battle_hooks(false)
  end
  it "should toggle battle hooks when battle is begun" do
    expect_swap_event_sets(@game.event_manager, @game, false)
    @game.battle_begun(nil, nil)
  end
  it "should toggle battle hooks when battle ends" do
    expect_swap_event_sets(@game.event_manager, @game, true)
    expect_keys_cleared(@game.player)
    @game.battle_completed
  end

  it "should toggle battle hooks when battle is begun" do
    expect_start_battle(@game.battle_layer, @game, :the_monster)
    @game.start_battle(:the_monster)
  end


  it "should get the current battle from the battle layer" do
    stub_battle(@game.battle_layer, :battle)
    @game.current_battle.should == :battle
  end

  it "should have all hooks" do
    stub_all_hooks(@game.event_handler, [:a, :b])
     @game.all_hooks.should == [:a, :b]
  end
  it "should remove all hooks" do
    stub_all_hooks(@game.event_handler, [:a, :b])
    expect_hook_removed(@game.event_handler, :a)
    expect_hook_removed(@game.event_handler, :b)
    @game.remove_all_hooks
  end

  it "should rebuild hud from the factory" do
    expect_make_hud(@factory, :the_new_hud)
    @game.rebuild_hud
    @game.hud.should == :the_new_hud
  end


  it "should step until a quit is thrown" do
    expect_fetch_sdl_events_to_throw_quit_event(@game.event_system.queue)
    @game.go
  end
end
