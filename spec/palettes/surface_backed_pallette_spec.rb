
require 'spec/rspec_helper'

describe SurfaceBackedPallette do
  before(:each) do
    @pallette = SurfaceBackedPallette.new("scaled-background-20x20.png", 20, 20)
  end

  it "should store tile size" do
    @pallette.tile_x.should == 20
    @pallette.tile_y.should == 20
  end

  it "should calculate offsets" do
    @pallette.offsets(:foo).should be_nil
  end
end
