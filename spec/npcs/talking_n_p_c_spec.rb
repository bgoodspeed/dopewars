
require 'spec/rspec_helper'

describe TalkingNPC do
  include DomainMocks

  before(:each) do
    @game = mock_game
    @universe = mock_universe
    @position = PositionedTileCoordinate.new(SdlCoordinate.new(1,2), SdlCoordinate.new(3,4))
    @npc = TalkingNPC.new(@player, @universe, "foobarbaz", "Charactern8.png", @position )
  end

  def expect_text_bound_to_layer(layer, text)
    layer.should_receive(:text=).with(text)
  end

  it "should be interactible" do
    expect_text_bound_to_layer(@universe.dialog_layer, "foobarbaz")
    @npc.interact(@game, @universe, @player)
  end
end
