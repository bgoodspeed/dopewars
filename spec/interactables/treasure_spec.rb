
require 'spec/rspec_helper'

describe Treasure do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @world = mock_world
    @player = mock_player
    @treasure = Treasure.new("treasure")
  end

  it "should block" do
    @treasure.is_blocking?.should be_true
  end
  
  it "should activate" do
    expect_treasure_sound_effect(@game.universe)
    expect_interaction_update(@world)
    expect_notification(@game)
    expect_inventory_added(@player)
    @treasure.activate(@game, @player, @world, 11, 22)
  end

  it "should be json ified" do
    @treasure.json_params.should be_an_instance_of(Array)
  end
end
