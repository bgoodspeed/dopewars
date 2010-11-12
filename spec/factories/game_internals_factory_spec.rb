
require 'spec/rspec_helper'

describe GameInternalsFactory do
  include DomainMocks

  before(:each) do
    @screen = mock_screen
    @universe = mock_universe
    @game = mock_game
    @factory = GameInternalsFactory.new
  end

  it "should build game pieces -- clock" do
    @factory.make_clock.should be_an_instance_of ClockFacade
  end
  it "should build game pieces -- player" do
    @factory.make_player(@screen, @universe, @game).should be_an_instance_of Player
  end
  it "should get the pallette" do
    @factory.pallette.should be_an_instance_of SurfaceBackedPallette
  end
  it "should get the palette larger" do
    @factory.pallette_160.should be_an_instance_of Pallette
  end
  it "should get the interaction palette" do
    @factory.interaction_pallette_160.should be_an_instance_of InteractableSurfaceBackedPallette
  end
  it "should make sound effect sets" do
    @factory.make_sound_effects.should be_an_instance_of SoundEffectSet
  end

  #TODO rename this method to make_event_helper
  it "should make event helper" do
    @factory.make_event_hooks(@game, [], [], [], [], [], [], []).should be_an_instance_of EventHelper
  end

  it "can build game worlds" do
    w1 = @factory.make_world1
    w2 = @factory.make_world2
    w3 = @factory.make_world3

    w1.should_not be_nil
    w2.should_not be_nil
    w3.should_not be_nil

    w1.should be_an_instance_of WorldState
    w2.should be_an_instance_of WorldState
    w3.should be_an_instance_of WorldState
  end

  it "can make npcs" do
    npc = @factory.make_npc(@player, @universe)
    npc.should be_an_instance_of TalkingNPC
  end
  it "can make monsters" do
    npc = @factory.make_monster(@player, @universe)
    npc.should be_an_instance_of Monster
  end

  it "can make event systems" do
    @factory.make_event_system(@game, [], [], [], [], [], [], []).should be_an_instance_of(EventSystem)
  end
  it "can make event manager" do
    @factory.make_event_manager.should be_an_instance_of(EventManager)
  end
  it "can make the screen" do
    @factory.make_screen.should be_an_instance_of(ScreenFacade)
  end
  it "can make the event queue" do
    @factory.make_queue.should be_an_instance_of(EventQueueFacade)
  end
  it "can make game layers" do
    @factory.make_game_layers(@screen, @game).should be_an_instance_of(GameLayers)
  end
  it "can make battle layer" do
    @factory.make_battle_layer(@screen, @game).should be_an_instance_of(BattleLayer)
  end
  it "can make menu layer" do
    @factory.make_menu_layer(@screen, @game).should be_an_instance_of(MenuLayer)
  end
  it "can make notifications layer" do
    @factory.make_notifications_layer(@screen, @game).should be_an_instance_of(NotificationsLayer)
  end
  it "can make dialog layer" do
    @factory.make_dialog_layer(@screen, @game).should be_an_instance_of(DialogLayer)
  end
  it "can make the hud" do
    @factory.make_hud(@screen, @player, @universe).should be_an_instance_of(Hud)
  end
  it "can make the universe" do
    @factory.make_universe([mock_world], mock("gl"), mock("sfx"), mock_game)
  end
end
