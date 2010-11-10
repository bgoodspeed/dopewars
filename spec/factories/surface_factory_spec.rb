
require 'spec/rspec_helper'

describe SurfaceFactory do
  before(:each) do
    @surface_factory = SurfaceFactory.new
  end

  it "should build surface facades" do
    surf = @surface_factory.make_surface([2,3])
    surf.should be_an_instance_of(SurfaceFacade)
    surf.w.should == 2
    surf.h.should == 3
  end
end
