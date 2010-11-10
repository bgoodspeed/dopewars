
require 'spec/rspec_helper'

describe TopoMapFactory do
  before(:each) do
    @topo_map_factory = TopoMapFactory.new
  end

  it "should build topo maps" do
    map = TopoMapFactory.build_map("world1_bg", 1280, 960)
    map.should be_an_instance_of TopoMap
    map.world_x.should == 1280
    map.world_y.should == 960
  end
end
