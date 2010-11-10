
require 'spec/rspec_helper'

describe WarpPoint do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @player = mock_player
    @warp_point = WarpPoint.new(42)
  end

  it "should store warp target world index" do
    @warp_point.destination.should == 42
  end
  it "should not block" do
    @warp_point.is_blocking?.should be_false
  end


  it "should be activatable" do
    expect_warp_sound_effect(@game.universe)
    expect_fades_out_bg_music(@game.universe)
    expect_world_change(@game.universe)
    expect_player_position_set(@player)
    expect_fades_in_bg_music(@game.universe)
    @warp_point.activate(@game, @player, mock_world, 69, 96)
  end
end
