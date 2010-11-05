# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

class FakeBlittable
  def initialize(key)
    @key = key
  end

  def blit(dest, offsets, py=nil, xi=nil, yi=nil)
    dest << @key
  end

end

class FakeTarget
  attr_reader :blitted
  def initialize(width=1, height=1)
    @blitted = []
    @width = width
    @height = height
  end
  def <<(other)
    @blitted << other
  end
  def w
    @width
  end
  def h
    @height
  end
end

class FakePallette
  def [](key)
    FakeBlittable.new(key.upcase)
  end
end

describe TopoMap do
  before(:each) do
    @topo = TopoMap.new(2,3, 200, 300, ['a', 'b','c','d','e','f'])
  end
  
  it "test_data_at" do
    @topo.data_at(0,0).should == 'a'
    @topo.data_at(1,0).should == 'b'
    @topo.data_at(1,1).should == 'd'
    @topo.data_at(1,2).should == 'f'
    @topo.data_at(0,2).should == 'e'
  end

  it "test_viewport_data" do
    @topo.viewport_data_for(0,0,1,1).should == ['a']
    @topo.viewport_data_for(0,0,1,2).should == ['a', 'c']
    @topo.viewport_data_for(0,0,2,1).should == ['a', 'b']
    @topo.viewport_data_for(0,0,2,2).should == ['a', 'b', 'c', 'd']
    @topo.viewport_data_for(1,0,1,1).should == ['b']
    @topo.viewport_data_for(1,0,1,2).should == ['b', 'd']
  end

  it "test_can_calculate_offsets_from_world_coords" do
    @topo.x_offset_for_world(0).should == 0
    @topo.x_offset_for_world(99).should == 0
    @topo.x_offset_for_world(101).should == 1

    @topo.y_offset_for_world(0).should == 0
    @topo.y_offset_for_world(99).should == 0
    @topo.y_offset_for_world(101).should == 1
    @topo.y_offset_for_world(199).should == 1
    @topo.y_offset_for_world(201).should == 2

  end

  def mock_blittable
    m = mock("blittable")
    m.stub!(:blit)
    m
  end

  def fake_pallette
    FakePallette.new
  end

  def fake_target(w=1, h=1)
    FakeTarget.new(w,h)
  end

  it "can blit to a pallette" do
    t = fake_target
    @topo.blit_to(fake_pallette, t)
    t.blitted.should == ["A", "B","C", "D", "E", "F"]
  end

  it "can blit to the foreground - one by one" do
    t = fake_target
    @topo.blit_foreground(fake_pallette, t, 0, 0)
    t.blitted.should == ["A"]
  end
  it "can blit to the foreground - wide" do
    t = fake_target(200,1)
    @topo.blit_foreground(fake_pallette, t, 0, 0)
    t.blitted.should == ["A", "B"]
  end
  it "can blit to the foreground - tall" do
    t = fake_target(1,200)
    @topo.blit_foreground(fake_pallette, t, 0, 0)
    t.blitted.should == ["A", "C"]
  end
  it "can blit to the foreground - large" do
    t = fake_target(200,200)
    @topo.blit_foreground(fake_pallette, t, 0, 0)
    t.blitted.should == ["A", "B", "C", "D"]
  end

  it "test_can_update_on_the_fly" do
    @topo.update(0,0,'X')
    @topo.data_at(0,0).should == 'X'
  end

  it "test_can_calculate_boundaries_from_tile_coords" do
    @topo.left_side(0).should == 0
    @topo.left_side(1).should == 100
    @topo.right_side(0).should == 100
    @topo.right_side(1).should == 200
    @topo.top_side(0).should == 0
    @topo.top_side(1).should == 100
    @topo.bottom_side(0).should == 100
    @topo.bottom_side(1).should == 200


  end

end

