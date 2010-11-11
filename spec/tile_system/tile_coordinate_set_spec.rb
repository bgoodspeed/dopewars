
require 'spec/rspec_helper'

describe TileCoordinateSet do
  before(:each) do
    @tile_coordinate_set = TileCoordinateSet.new(-10, 10, -8, 8)
  end

  it "should store min/max for x/y" do
    @tile_coordinate_set.minx.should == -10
    @tile_coordinate_set.maxx.should == 10
    @tile_coordinate_set.miny.should == -8
    @tile_coordinate_set.maxy.should == 8
  end
end
