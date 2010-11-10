
require 'spec/rspec_helper'

describe GameInternalsFactory do
  include DomainMocks

  before(:each) do
    @screen = mock_screen
    @universe = mock_universe
    @game = mock_game
    @game_internals_factory = GameInternalsFactory.new
  end

  it "should build game pieces -- clock" do
    @game_internals_factory.make_clock.should be_an_instance_of ClockFacade
  end
  it "should build game pieces -- player" do
    @game_internals_factory.make_player(@screen, @universe, @game).should be_an_instance_of Player
  end
end
