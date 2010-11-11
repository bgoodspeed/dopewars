
require 'spec/rspec_helper'

describe SdlCoordinate do
  before(:each) do
    @coordinate = SdlCoordinate.new(:x, :y)
  end

  it "should be define x and y" do
    @coordinate.x.should == :x
    @coordinate.y.should == :y
  end
end
