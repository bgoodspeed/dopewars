
require 'spec/rspec_helper'

describe Universe do
  include DomainMocks
  before(:each) do
    @world = mock_world
    @world2 = mock_world
    @universe = Universe.new(0, [@world, @world2], @layers, @sfx, @game)
    @universe2 = Universe.new(0, [@world, @world2], @layers, @sfx, @game)
  end

  it "should save current world" do
    @universe.current_world.should == @world
  end

  it "should be able to get worlds by index" do
    @universe.world_by_index(0).should == @world
    @universe.world_by_index(1).should == @world2
  end
  it "should be able to set world by index" do
    @universe.set_current_world_by_index(1)
    @universe.current_world.should == @world2
  end

  it "can replace world data" do
    expect_replace_pallettes(@world)
    expect_replace_pallettes(@world2)
    expect_replace_bgsurface(@world)
    expect_replace_bgsurface(@world2)
    expect_replace_bgmusic(@world)
    expect_replace_bgmusic(@world2)
    @universe.replace_world_data(@universe2)
  end

  it "is json ified" do
    @universe.json_params.should be_an_instance_of Array
  end

  it "can reblit background" do
    expect_reblit_background(@world)
    expect_reblit_background(@world2)
    @universe.reblit_backgrounds
  end
end
