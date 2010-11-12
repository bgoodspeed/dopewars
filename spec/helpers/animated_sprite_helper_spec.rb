
require 'spec/rspec_helper'

describe AnimatedSpriteHelper do
  before(:each) do
    position = PositionedTileCoordinate.new(SdlCoordinate.new(1, 2), SdlCoordinate.new(3, 4))
    @helper = AnimatedSpriteHelper.new("Charactern8.png", position)
  end

  def with_frame(key)
    @helper.set_frame_from(key)
    @helper.last_direction_offset
  end

  it "should set frame from keys" do
    with_frame(:down).should == 0
    with_frame(:efasdf).should == 0
    with_frame(:left).should == 4
    with_frame(:asdf).should == 4
    with_frame(:right).should == 8
    with_frame(:foo).should == 8
    with_frame(:up).should == 12

  end
end
