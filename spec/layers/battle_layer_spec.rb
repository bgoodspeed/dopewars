
require 'spec/rspec_helper'

describe BattleLayer do
  include DomainMocks
  include DelegationMatchers
  before(:each) do
    @game = mock_game
    @screen = mock_screen
    @monster = mock_monster
    @layer = BattleLayer.new(@screen, @game)
  end

  it "should start out inactive" do
    @layer.active.should be_false
  end
  it "should start out without a battle" do
    @layer.battle.should be_nil
  end
  
  it "should start fights " do
    @layer.start_battle(@game, @monster)
    @layer.battle.should_not be_nil
    @layer.active.should be_true
  end

  it "should end fights " do
    @layer.start_battle(@game, @monster)
    expect_experience_query(@monster, 3)
    monster_inventory = expect_inventory_query(@monster)
    expect_battle_completed(@game)
    expect_gain_experience(@game.player, 3)
    expect_gain_inventory(@game.player, monster_inventory)
    expect_delete_monster(@game.universe.current_world, @monster)
    @layer.end_battle
    @layer.active.should be_false
  end

  it "should make menu layer configs" do
    @layer.menu_layer_config.should be_an_instance_of(MenuLayerConfig)
    @layer.end_battle_menu_layer_config.should be_an_instance_of(MenuLayerConfig)
  end

  it "should make cursor configs for battle participants" do
    @layer.battle_text_config_with_actions([]).should be_an_instance_of(BattleParticipantCursorTextRenderingConfig)
  end

  it "should update -- nothing to do" do
    @layer.update(mock_event)
  end
  
  it "should update -- in battle case" do
    @layer.start_battle(@game, @monster)
    expect_accumulate_readiness(@layer.battle)
    @layer.update(mock_event)
  end

  it "should rebuild menus" do
    @layer.rebuild_menu
    @layer.menu.should_not be_nil
  end

  it "should delegate cursor commands" do
    @layer.rebuild_menu
    @layer.should delegate_to({:move_cursor_up => [@layer.menu]}, {:cursor_helper => :move_cursor_up})
    @layer.should delegate_to({:move_cursor_down => [@layer.menu]}, {:cursor_helper => :move_cursor_down})
    @layer.should delegate_to({:enter_current_cursor_location => [@layer.menu]}, {:cursor_helper => :activate})
    @layer.should delegate_to({:current_selected_menu_entry_name => [@layer.menu]}, {:cursor_helper => :current_selected_menu_entry_name})
    @layer.should delegate_to({:current_menu_entries => [@layer.menu]}, {:cursor_helper => :current_menu_entries})
  end

  it "can be drawn" do
    @layer.start_battle(@game, @monster)
    @layer.rebuild_menu
    expect_draw_to(@monster)
    stub_battle_layer_query(@game, @layer)
    expect_blitted(@layer.layer)
    expect_draw(@layer.battle_hud)
    @layer.draw
  end

  
  it "can draw the after battle menu too" do
    @layer.start_battle(@game, @monster)
    @layer.rebuild_menu
    stub_battle_over(@layer.battle)
    stub_battle_layer_query(@game, @layer)
    expect_blitted(@layer.layer)
    expect_draw(@layer.end_menu)
    @layer.draw
  end

  it "can draw the after battle menu too" do
    @layer.start_battle(@game, @monster)
    @layer.rebuild_menu
    stub_battle_over(@layer.battle)
    stub_player_dead(@layer.battle)
    stub_battle_layer_query(@game, @layer)
    expect_blitted(@layer.layer)
    expect_draw(@layer.end_menu)
    @layer.draw
  end
end
