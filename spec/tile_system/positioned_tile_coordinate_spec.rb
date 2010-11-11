
require 'spec/rspec_helper'

describe PositionedTileCoordinate do
  before(:each) do
    @coordinate = PositionedTileCoordinate.new(:foo, :bar)
  end

  it "should bind arguments in order" do
    @coordinate.position.should == :foo
    @coordinate.dimension.should == :bar
  end
end
