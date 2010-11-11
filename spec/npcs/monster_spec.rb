
require 'spec/rspec_helper'

describe Monster do
  include DomainMocks
  
  before(:each) do
    @player = mock_player
    @game = mock_game
    @universe = mock_universe
    @position = PositionedTileCoordinate.new(SdlCoordinate.new(1,2), SdlCoordinate.new(3,4))

    @monster = Monster.new(@player, @universe, "Charactern8.png", @position)
  end

  def expect_battle_begun(m)
    m.should_receive(:battle_begun)
    m.should_receive(:start_battle)
  end

  it "should interactable and start fights" do
    expect_battle_begun(@game)
    @monster.interact(@game, @universe, @player)
  end
end
