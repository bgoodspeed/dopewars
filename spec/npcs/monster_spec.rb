
require 'spec/rspec_helper'

describe Monster do
  include DomainMocks
  
  before(:each) do
    @player = mock_player
    @game = mock_game
    @universe = mock_universe
    @position = PositionedTileCoordinate.new(SdlCoordinate.new(1,2), SdlCoordinate.new(3,4))

    @monster = Monster.new(@player, @universe, "Charactern8.png", @position, nil, nil, mock_ai)
  end

  def expect_battle_begun(m)
    m.should_receive(:battle_begun)
    m.should_receive(:start_battle)
  end

  it "should interactable and start fights" do
    expect_battle_begun(@game)
    @monster.interact(@game, @universe, @player)
  end

  it "is not blocking" do
    @monster.is_blocking?.should be_false
  end

  it "can draw by blit" do
    expect_blitted(@monster.animated_sprite_helper.image)
    @monster.draw(nil, 1,2,3,4)
  end
  it "can draw to a surface by blit" do
    expect_blitted(@monster.animated_sprite_helper.image)
    @monster.draw_to(nil)
  end

  it "can be updated" do
    expect_update_animation(@monster.animation_helper)
    expect_update_accel(@monster.coordinate_helper)
    expect_update_vel(@monster.coordinate_helper)
    expect_update_pos(@monster.coordinate_helper)
    expect_update(@monster.ai)
    @monster.update(mock_event)
  end

  it "can calculate distance to a point" do
    @monster.distance_to(0,0).should == [1,2]
    @monster.distance_to(-3,4).should == [4,2]
  end
  it "can calculate nearby with a threshold" do
    @monster.nearby?(1,2, 1,1).should be_true
    @monster.nearby?(1,4, 1,1).should be_false
    @monster.nearby?(1,4, 1,3).should be_true
  end

  it "should add readiness and take turn when ready" do
    stub_ready(@monster.readiness_helper)
    expect_add_readiness(@monster.readiness_helper)
    expect_take_battle_turn(@monster.ai, @monster, :ziebattle)
    @monster.add_readiness(1, :ziebattle)
  end
  it "should add readiness but not take a turn if not ready" do
    stub_ready(@monster.readiness_helper, false)
    expect_add_readiness(@monster.readiness_helper)
    @monster.add_readiness(1, :ziebattle)
  end

  it "is json ified" do
    @monster.json_params.should be_an_instance_of Array
  end

end
