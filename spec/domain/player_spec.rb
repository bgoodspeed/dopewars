
require 'spec/rspec_helper'

describe Player do
  include DomainMocks
  before(:each) do
    @position = PositionedTileCoordinate.new(SdlCoordinate.new(1,2), SdlCoordinate.new(16,64))
    @game = mock_game
    @universe = mock_universe
    @party = mock_party
    @player = Player.new(@position, @universe, @party, "Charactern8.png", 123, 435, @game)
  end

  it "should be able to interact" do
    @player.interact_with_facing(@game)
  end

  it "should be able to update" do
    @player.update(mock_event)
  end

  it "should track facing direction" do
    @player.facing.should == :down
    @player.update_facing_if_key_matches(:left)
    @player.facing.should == :left
    @player.update_facing_if_key_matches(:monkeys)
    @player.facing.should == :left
  end

  it "should update the sprite helper" do
    expect_set_frame_from(@player.animated_sprite_helper, :left)
    expect_replace_avatar(@player.animated_sprite_helper)
    @player.update_animated_sprite_helper(:left)
  end

  it "should know the x and y extensions of the player avatar" do
    @player.x_ext.should == 8
    @player.y_ext.should == 32
  end

  it "should react to key releases" do
    expect_delete_key(@player.keys, :foo)
    @player.key_released(mock_event(:foo))
  end
  it "should react to key presses" do
    expect_add_key(@player.keys, :foo)
    @player.key_pressed(mock_event(:foo))
  end

  it "should set position" do
    expect_set_position(@player.coordinate_helper, 111, 222)
    @player.set_position(111, 222)
  end

  it "should set key presses for " do
    expect_set_timed_keypress(@player.keys, :foo, 12)
    @player.set_key_pressed_for(:foo, 12)
  end
  it "should set key presses for time" do
    expect_set_timed_keypress_in_ms(@player.keys, :foo, 12)
    @player.set_key_pressed_for_time(:foo, 12)
  end

  it "can get inventory size" do
    stub_inventory_count(@player.party, 19)
    @player.inventory_count.should == 19
  end

  #TODO make a json matcher
  it "is json-ified" do
    @player.json_params.should be_an_instance_of Array
  end

  it "can draw by blit ops" do
    expect_blitted(@player.animated_sprite_helper.image)
    @player.draw(mock_screen)
  end
end
