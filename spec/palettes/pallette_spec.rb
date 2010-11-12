
require 'spec/rspec_helper'

describe Pallette do
  include DomainMocks
  before(:each) do
    @surface = mock_surface
    @pallette = Pallette.new(:foo)
    @other = Pallette.new(:foo, {0 => :other})
  end

  it "should get default values" do
    @pallette[0].should == :foo
    @other[0].should == :other
  end
  
  it "should get/setvalues" do
    @pallette[0] = :bar
    @pallette[0].should == :bar
  end

  it "can blit to draw" do
    expect_blitted(@surface)
    @pallette.blit(0,0, 0, @surface, 0, 0)
  end
end
