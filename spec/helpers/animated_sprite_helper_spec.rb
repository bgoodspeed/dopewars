
require 'spec/rspec_helper'

describe AnimatedSpriteHelper do
  before(:each) do
    position = PositionedTileCoordinate.new(SdlCoordinate.new(1, 2), SdlCoordinate.new(3, 4))
    @animated_sprite_helper = AnimatedSpriteHelper.new("Charactern8.png", position)
  end

  it "should be described" do
    #TODO not complete
  end
end
