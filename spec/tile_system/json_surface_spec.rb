
require 'spec/rspec_helper'

describe JsonSurface do
  include MethodDefinitionMatchers
  
  before(:each) do
    @surface = JsonSurface.new([3,4])
  end

  #TODO review saving/loading, maybe don't need this class
  it "should be respect dims" do
    @surface.w.should == 3
    @surface.h.should == 4
  end
  it "should be blittable" do
    @surface.should define(:blit)
  end
end
