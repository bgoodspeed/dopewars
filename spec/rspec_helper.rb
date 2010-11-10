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

module DomainMocks

  def mock_attributes
    m = mock("attributes")
    m
  end

  def named_mock(name)
    m = mock("named mock: #{name}")
    m.stub!(:name).and_return name
    m
  end

  def mock_event
    m = mock("event")

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
    m
  end

  def mock_hero
    h = mock("hero")
    h
  end

  def expect_readiness_consumed(m)
    m.should_receive(:consume_readiness)
  end

  def expect_item_consumed(hero, item)
    hero.should_receive(:consume_item).with(item)
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

  def expect_interaction_update(world)
    world.should_receive(:update_interaction_map)
  end

  def expect_notification(world)
    world.should_receive(:add_notification)
  end

  def expect_inventory_added(p)
    p.should_receive(:add_inventory)
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


  def mock_world_weapon
    m = mock("world weapon")
    
    m
  end

  def mock_player
    m = mock("player")
    m.stub!(:party).and_return mock_party
    m.stub!(:world_weapon).and_return mock_world_weapon
    m.stub!(:px).and_return 1122
    m.stub!(:py).and_return 3344
    m.stub!(:facing).and_return :down
    m
  end

  def mock_layer
    m = mock("layer")
    m
  end

  def mock_world
    m = mock("world")
    m.stub!(:x_offset_for_world).and_return 42
    m.stub!(:y_offset_for_world).and_return 69
    m.stub!(:x_offset_for_interaction).and_return 42
    m.stub!(:y_offset_for_interaction).and_return 69
    m
  end

  def mock_universe
    m = mock("universe")
    m.stub!(:current_world).and_return mock_world
    m.stub!(:x_offset_for_world).and_return 42
    m.stub!(:y_offset_for_world).and_return 69
    m.stub!(:x_offset_for_interaction).and_return 42
    m.stub!(:y_offset_for_interaction).and_return 69


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
