require 'rubygems'
require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'

module MockeryHelp
  def mocking(conf)
    m = mock
    conf.each {|k,v| m.stub!(k).and_return(v) }
    m
  end
end

module MethodDefinitionMatchers
  class MethodDefinedMatcher
    def initialize(name)
      @name = name
    end

    def matches?(other)
      @other = other
      other.respond_to?(@name)
    end

    def failure_message
      "Expected #{@other} to define #{@name}"
    end

  end

  def define(method_name)
    MethodDefinedMatcher.new(method_name)
  end

end

module DomainExpectations

  def expect_inventory_query(m)
    m.should_receive(:inventory).and_return :fake_inventory
    :fake_inventory
  end

  def expect_delete_monster(m, monster)
    m.should_receive(:delete_monster).with(monster)
  end

  def expect_draw_to(m)
    m.should_receive(:draw_to)
  end

  def expect_experience_query(m, value)
    m.should_receive(:experience).and_return value
  end
  def expect_gain_experience(m, value)
    m.should_receive(:gain_experience).with(value)
  end
  def expect_gain_inventory(m, value)
    m.should_receive(:gain_inventory).with(value)
  end

  def expect_battle_completed(m)
    m.should_receive(:battle_completed)
  end

  def expect_accumulate_readiness(m)
    m.should_receive(:accumulate_readiness)
  end

  def expect_readiness_consumed(m)
    m.should_receive(:consume_readiness)
  end

  def expect_item_consumed(hero, item)
    hero.should_receive(:consume_item).with(item)
  end

  def expect_set_frame_from(m, key)
    m.should_receive(:set_frame_from).with(key)
  end
  def expect_world_change(uni)
    uni.should_receive(:set_current_world_by_index)
  end

  def expect_fades_out_bg_music(uni)
    uni.should_receive(:fade_out_bg_music)
  end

  def expect_fades_in_bg_music(uni)
    uni.should_receive(:fade_in_bg_music)
  end

  def expect_sound_effect(uni, effect)
    uni.should_receive(:play_sound_effect).with(effect)
  end
  def expect_set_timed_keypress(m, key, v)
    m.should_receive(:set_timed_keypress).with(key, v)
  end

  def expect_replace_bgmusic(m)
    m.should_receive(:replace_bgmusic)
  end
  def expect_replace_bgsurface(m)
    m.should_receive(:replace_bgsurface)
  end
  def expect_replace_pallettes(m)
    m.should_receive(:replace_pallettes)
  end

  def expect_reblit_background(m)
    m.should_receive(:reblit_background)
  end
  def expect_set_timed_keypress_in_ms(m, key, v)
    m.should_receive(:set_timed_keypress_in_ms).with(key, v)
  end
  def expect_set_position(m,x,y)
    m.should_receive(:px=).with(x)
    m.should_receive(:py=).with(y)
  end

  def expect_add_key(m, key)
    m.should_receive(:add_key).with(key)
  end
  def expect_delete_key(m, key)
    m.should_receive(:delete_key).with(key)
  end

  def expect_replace_avatar(m)
    m.should_receive(:replace_avatar)
  end

  def expect_interaction_update(world)
    world.should_receive(:update_interaction_map)
  end

  def expect_notification(world)
    world.should_receive(:add_notification)
  end

  def expect_inventory_added(p)
    p.should_receive(:add_inventory)
  end

  def expect_draw(m)
    m.should_receive(:draw)
  end
  def expect_swap_event_sets(m, game, active)
    m.should_receive(:swap_event_sets).with(game, active, anything, anything)
  end

  def expect_warp_sound_effect(uni)
    expect_sound_effect(uni, "warp")
  end

  def expect_treasure_sound_effect(uni)
    expect_sound_effect(uni, "treasure")
  end

  def expect_player_position_set(p)
    p.should_receive(:set_position)
  end
  def expect_blitted(m)
    m.should_receive(:blit)
  end
  def expect_current_battle_participant_offset(m, posn)
    m.should_receive(:current_battle_participant_offset).with(posn).and_return :expected_offset
  end

  def expect_draw_weapon(m)
    m.should_receive(:draw_weapon)
  end

  def expect_event_handled(m)
    m.should_receive(:handle)
  end

  def expect_enter_current_cursor_location(m)
    m.should_receive(:enter_current_cursor_location)
  end

  def expect_event_added(m)
    m.should_receive(:<<)
  end

  def expect_interact_with_facing(m, value)
    m.should_receive(:interact_with_facing).with(value)
  end

  def expect_fetch_sdl_events_to_throw_quit_event(m)
    m.should_receive(:fetch_sdl_events).and_throw(:quit)
  end


  def expect_toggle_activity(m)
    m.should_receive(:toggle_activity)
  end
  def expect_lifetime_sequence(m)
    m.should_receive(:lifetime).at_least(1).and_return(0, 100, 200, 300)
  end
  def expect_reset_indices(m)
    m.should_receive(:reset_indices)
  end
  def expect_hook_removed(m,value)
    m.should_receive(:remove_hook).with(value)
  end

  def expect_make_hud(m, v)
    m.should_receive(:make_hud).and_return v
  end

  def expect_rotozoom(m)
    m.should_receive(:rotozoom).and_return m
  end
  def expect_colorkey_set(m)
    m.should_receive(:get_at).with(0,0).and_return :foo
    m.should_receive(:colorkey=).with(:foo)
  end

  def expect_start_battle(m, game, monster)
    m.should_receive(:start_battle).with(game, monster)
  end
  def expect_keys_cleared(m)
    m.should_receive(:clear_keys)
  end

  def expect_fade_out(m)
    m.should_receive(:fade_out)
  end
  def expect_pause(m)
    m.should_receive(:pause)
  end
  def expect_play(m)
    m.should_receive(:play)
  end

end

module DomainStubs
  def stub_menu_layer_active(m, is_active=true)
    m.stub!(:active?).and_return is_active
  end
  def stub_queue_with_events(m)
    m.stub!(:queue).and_return [mock_event]
  end
  def stub_using_weapon(m)
    m.stub!(:using_weapon?).and_return true
  end
  def stub_battle_layer_query(m, layer)
    m.stub!(:battle_layer).and_return layer
  end

  def stub_battle_over(m)
    m.stub!(:over?).and_return true
  end
  def stub_player_dead(m)
    m.stub!(:player_alive?).and_return false
  end

  def stub_battle(m, battle)
    m.stub!(:battle).and_return battle
  end

  def stub_all_hooks(m, hooks)
    m.stub!(:hooks).and_return hooks
  end

  def stub_music_playing(m, rv=true)
    m.stub!(:playing?).and_return rv
  end

end

module DomainMocks
  include DomainExpectations
  include DomainStubs
  def mock_attributes
    m = mock("attributes")
    m
  end

  def mock_event_hook
    m = mock("event_hook")
    m
  end

  def mock_event_handler
    m = mock("event_handler")
    m
  end

  def mock_surface
    m = mock("surface")
    m.stub!(:surface).and_return m
    m.stub!(:w).and_return 240
    m.stub!(:h).and_return 110
    m
  end
  def mock_trigger_factory
    m = mock("trigger_factory")
    m.stub!(:make_key_press_event_hook).and_return mock_event_hook
    m.stub!(:make_event_hook).and_return mock_event_hook
    m.stub!(:make_event_handler).and_return mock_event_handler
    m
  end

  def mock_game_internals_factory
    m = mock("game_internals_factory")
    m.stub!(:make_screen).and_return mock_screen
    m.stub!(:make_world1).and_return mock_world
    m.stub!(:make_world2).and_return mock_world
    m.stub!(:make_world3).and_return mock_world
    m.stub!(:make_universe).and_return mock_universe
    m.stub!(:make_player).and_return mock_player
    m.stub!(:make_npc).and_return mock_npc
    m.stub!(:make_hud).and_return mock_hud
    m.stub!(:make_game_layers).and_return mock_game_layers
    m.stub!(:make_sound_effects).and_return mock_sound_effects
    m.stub!(:make_monster).and_return mock_monster
    m.stub!(:make_event_system).and_return mock_event_system
    m.stub!(:make_event_manager).and_return mock_event_manager
    m
  end

  def mock_event_manager
    m = mock("event_manager")
    m
  end

  def mock_hook
    m = mock("hook")
    m
  end

  def mock_event_system
    m = mock("event_system")
    m.stub!(:queue).and_return mock_queue
    m.stub!(:clock).and_return mock_clock
    m.stub!(:lifetime).and_return(0,100, 200) #XXX this is a tad hackish...
    m.stub!(:non_menu_hooks).and_return [mock_hook]
    m.stub!(:menu_active_hooks).and_return [mock_hook]
    m.stub!(:battle_active_hooks).and_return [mock_hook]
    m
  end



  def mock_clock
    m = mock("clock")
    m.stub!(:tick).and_return mock_event
    m
  end
  def mock_queue
    m = mock("queue")
    m.stub!(:fetch_sdl_events).and_return []
    m.stub!(:<<).and_return []
    m.stub!(:each)
    m
  end
  def mock_sound_effects
    m = mock("sound_effects")
    m
  end
  def mock_game_layers
    m = mock("game_layers")
    m
  end
  def mock_hud
    m = mock("hud")
    m.stub!(:update)
    m.stub!(:draw)
    m
  end
  def mock_npc
    m = mock("npc")
    m
  end
  def named_mock(name)
    m = mock("named mock: #{name}")
    m.stub!(:name).and_return name
    m
  end

  def mock_event(key=:left, secs=0.02)
    m = mock("event")
    m.stub!(:seconds).and_return secs
    m.stub!(:key).and_return key
    m
  end
  def mock_item
    m = mock("item")
    m
  end
  def mock_wrapper
    m = mock("surface wrapper")
    m.stub!(:tile_x).and_return 0
    m.stub!(:tile_y).and_return 0
    m
  end

  def mock_screen
    m = mock("screen")
    m.stub!(:w).and_return 640
    m.stub!(:h).and_return 480
    m.stub!(:fill)
    m.stub!(:update)
    m
  end

  def mock_hero
    h = mock("hero")
    h
  end

  def mock_monster(alive=true)
    m = mock("monster")
    m.stub!(:dead?).and_return !alive
    m
  end


  def mock_world_weapon
    m = mock("world weapon")
    
    m
  end

  def mock_player
    m = mock("player")
    m.stub!(:party).and_return mock_party
    m.stub!(:world_weapon).and_return mock_world_weapon
    m.stub!(:using_weapon?).and_return false
    m.stub!(:px).and_return 1122
    m.stub!(:py).and_return 3344
    m.stub!(:facing).and_return :down
    m.stub!(:dead?).and_return false
    m.stub!(:draw)
    m
  end

  def mock_layer
    m = mock("layer")
    m.stub!(:active=)
    m.stub!(:active).and_return false
    m
  end

  def mock_interpreter(walking=true)
    m = mock("interpreter")
    m.stub!(:interpret)
    m.stub!(:top_side).and_return 3
    m.stub!(:can_walk_at?).and_return walking
    m
  end

  def mock_no_walking_interpreter
    mock_interpreter(false)
  end

  def mock_colliding(is_colliding=true)
    m = mock("colliding")
    m.stub!(:collides_on_x?).and_return is_colliding
    m.stub!(:collides_on_y?).and_return is_colliding
    m
  end

  def mock_blocking(is_blocking=true)
    m = mock("blocking")
    m.stub!(:is_blocking?).and_return is_blocking
    m
  end

  def mock_world
    m = mock("world")
    m.stub!(:npcs).and_return []
    m.stub!(:x_offset_for_world).and_return 42
    m.stub!(:y_offset_for_world).and_return 69
    m.stub!(:x_offset_for_interaction).and_return 42
    m.stub!(:y_offset_for_interaction).and_return 69
    m.stub!(:interaction_interpreter).and_return mock_interpreter
    m.stub!(:topo_interpreter).and_return mock_interpreter
    m.stub!(:add_npc)
    
    m
  end

  def mock_player_holder
    m = mock("player holder (game)")
    m.stub!(:player).and_return mock_player
    m
  end

  def mock_universe
    m = mock("universe")
    
    m.stub!(:current_world).and_return mock_world
    m.stub!(:x_offset_for_world).and_return 42
    m.stub!(:y_offset_for_world).and_return 69
    m.stub!(:x_offset_for_interaction).and_return 42
    m.stub!(:y_offset_for_interaction).and_return 69
    m.stub!(:game).and_return mock_player_holder
    m.stub!(:battle_layer).and_return mock_layer
    m.stub!(:dialog_layer).and_return mock_layer
    m.stub!(:menu_layer).and_return mock_layer
    m.stub!(:npcs).and_return [mock_npc]
    
    m.stub!(:blit_world)
    m.stub!(:draw_game_layers_if_active)

    m
  end

  #TODO update all these mocks so that they auto-verify their mocked classes
  #TODO ie mock_class(ClassName) -> mock("class name"), needs a fully constructed
  #TODO instance to compare to and run "respond_to?" for all mocked symbols
  def mock_interaction_helper
    m = mock("interaction helper")

    m
  end

  def monster(player, universe)
    MonsterFactory.new.make_monster(player, universe)
  end

  def hero(name)
    h = Hero.new(name, nil, 1, 1, CharacterAttribution.new(
                                    CharacterState.new(
                                      CharacterAttributes.new(10,1,2,3,4,5,6,7)
                                    ), nil))
    h
  end

  def item(name)
    i = InventoryItem.new(1, GameItem.new(name, ItemState.new(ItemAttributes.none)))
    i
  end
  def mock_text_rendering_helper
    m = mock("text rendering helper")
    m.stub!(:render_lines_to_layer)
    m
  end

  def mock_menu_layer
    m = mock("menu layer")
    m.stub!(:text_rendering_helper).and_return mock_text_rendering_helper
    m
  end
  def mock_game
    g = mock("game")
    g.stub!(:player_missions).and_return([named_mock("mission 1")])
    g.stub!(:party_members).and_return([hero("person a"), hero("person b")])
    g.stub!(:inventory_info).and_return([item("item 1")])
    g.stub!(:menu_layer).and_return(mock_menu_layer)
    g.stub!(:player).and_return(mock_player)
    g.stub!(:universe).and_return(mock_universe)

    g
  end

  def mock_party
    m = mock("party")
    m.stub!(:members).and_return [hero("ALPHA"), hero("BETA")]
    m
  end




  def mock_action
    g = mock("action")
    g
  end

end

module MenuSelectorMatchers
  class MenuSelectorMatcher
    def matches?(target)
      @target = target
      props = [ target.size(nil).kind_of?(Numeric) ,
        target.elements(nil).is_a?(Array),
        target.selection_type.is_a?(Class) ]

      failures = props.select {|prop| !prop}
      
      failures.size == 0
    end

    def failure_message
      "#{@target.class} must define 'size->Numeric', 'elements->Array' and 'selection_type->Class'"
    end
  end

  def behave_as_a_menu_selector
    MenuSelectorMatcher.new
  end
end


module DelegationMatchers
  class DelegateToMatcher
    def initialize(sym_and_args, config)
      @sym = sym_and_args.keys[0]
      @args = sym_and_args.values[0]

      @exp_delegate = config.keys[0]
      @exp_delegate_method = config.values[0]
    end

    def matches?(target)
      m = Spec::Mocks::Mock.new("mock for #{target}.#{@exp_delegate}")
      m.should_receive(@exp_delegate_method).with(*@args)
      target.send("#{@exp_delegate}=", m)
      target.send(@sym, *@args)
      m
    end

    def failure_message_for_should
      "idano, you failed, whatever"
    end
    def failure_message_for_should_not
      "idano, you failed, whatever"
    end

  end

  def delegate_to(sym, config)
    DelegateToMatcher.new(sym, config)
  end

end


module WorldMapMatchers
  class NearEnoughToMatcher
    @@NEARNESS_THRESHOLD= 1.5
    def initialize(base)
      @base = base
    end

    def cmp_axis(idx, target)
      error = (@base[idx] - target[idx]).abs
      error < @@NEARNESS_THRESHOLD
    end

    def matches?(target)
      @target = target
      cmp_axis(0, target) && cmp_axis(1, target)
    end

    def fmt(array)
      array.join(",")
    end

    def failure_msg(is_not="")
      "#{fmt(@base)} expected #{is_not} to be within #{@@NEARNESS_THRESHOLD} of #{fmt(@target)}"
    end
    def failure_message_for_should
      failure_msg
    end
    def failure_message_for_should_not
      failure_msg("not")
    end

  end

  def be_near_enough_to(base)
    NearEnoughToMatcher.new(base)
  end

end


module UtilityMatchers
  class ContainingMatcher
    @@NEARNESS_THRESHOLD= 1.5
    def initialize(base)
      @base = base
    end

    def matches?(target)
      target.include?(@base)
      @target = target
    end

    def fmt(array)
      array.join(",")
    end

    def failure_msg(is_not="")
      "#{fmt(@base)} expected #{is_not} to contain #{fmt(@target)}"
    end
    def failure_message_for_should
      failure_msg
    end
    def failure_message_for_should_not
      failure_msg("not")
    end

  end

  def contain?(base)
    ContainingMatcher.new(base)
  end

end
