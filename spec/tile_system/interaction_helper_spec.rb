
require 'spec/rspec_helper'

describe InteractionHelper do
  include DomainMocks

  before(:each) do
    @game = mock_game
    @policy = InteractionPolicy.immediate_return
    @tile = mock("tile")
    @npc = mock_npc
    @layer = mock("layer")
    @interaction_helper = InteractionHelper.new(@game, @policy)
  end

  it "should be interactable" do
    @interaction_helper.interact_with_facing(@game, 123, 456)
  end

  def facing_distance(facing)
    @interaction_helper.facing = facing
    @interaction_helper.facing_tile_distance_for(@game, 1, 1, 0, 0)
  end

  it "can calculate facing" do
    @interaction_helper.calculate_facing([:down],[], 42).should == 42
    @interaction_helper.calculate_facing([],[:down], 42).should == 41
  end
  it "can determine the distance to the facing tile" do
    facing_distance(:down).should == 3
    facing_distance(:left).should == 18
    facing_distance(:right).should == 60
    facing_distance(:up).should == 7
  end

  it "can interact with a tile" do
    expect_activate(@tile)
    @interaction_helper.interact_with_tile(@game, 1, 1, @tile)
  end

  it "can interact with dialog" do
    expect_toggle_activity(@game.universe.dialog_layer)
    @interaction_helper.interact_with_dialog(@game.universe.dialog_layer)
  end

  it "can interact with npc" do
    expect_interact(@npc)
    @interaction_helper.interact_with_npc(@game, [@npc])
  end

  it "attempts interaction with the dialog layer" do
    stub_active(@layer, true)
    expect_toggle_activity(@layer)
    @interaction_helper.attempt_interaction_with_dialog(@layer).should be_true
  end
  
  it "attempts interaction with the current tile" do
    expect_activate(@tile)
    @interaction_helper.attempt_interaction_with_tile(@game, 1,2, @tile).should be_true
  end

  it "attempts interaction with the facing tile" do
    expect_activate(@tile)
    @interaction_helper.attempt_interaction_with_facing(@game, 1,2, @tile, true).should be_true
  end

  it "attempts interaction with npcs" do
    expect_interact(@npc)
    @interaction_helper.attempt_interaction_with_npcs(@game, [@npc]).should be_true
    @interaction_helper.attempt_interaction_with_npcs(@game, []).should be_false
  end

end
