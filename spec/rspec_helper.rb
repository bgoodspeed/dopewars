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



module DomainMocks
  def named_mock(name)
    m = mock("named mock: #{name}")
    m.stub!(:name).and_return name
    m
  end

  def mock_player
    m = mock("player")
    m.stub!(:party).and_return mock_party
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
    m
  end



  def monster(player, universe)
    MonsterFactory.new.make_monster(player, universe)
  end

  def hero(name)
    h = Hero.new(name,nil, 1, 1, CharacterAttribution.new(CharacterState.new(CharacterAttributes.new(0,1,2,3,4,5,6,7)), nil))
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
    m.stub!(:members).and_return [named_mock("ALPHA"), named_mock("BETA")]
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
      props = [ target.size.kind_of?(Numeric) ,
        target.elements.is_a?(Array),
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
