
require 'spec/rspec_helper'

describe Player do
  include DomainMocks
  before(:each) do
    @position = PositionedTileCoordinate.new(SdlCoordinate.new(1,2), SdlCoordinate.new(3,4))
    @game = mock_game
    @universe = mock_universe
    @player = Player.new(@position, @universe, @party, "Charactern8.png", 123, 435, @game)
  end

  it "should be able to interact" do
    @player.interact_with_facing(@game)
  end
end
