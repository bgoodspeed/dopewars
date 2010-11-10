
require 'spec/rspec_helper'

describe MonsterCoordinateHelper do
  include DomainMocks
  before(:each) do
    posn_coords = SdlCoordinate.new(123, 987)
    dim_coords = SdlCoordinate.new(33, 44)
    posn = PositionedTileCoordinate.new(posn_coords, dim_coords)
    @coordinate_helper = MonsterCoordinateHelper.new(posn, :foo, mock_universe)
  end

  it "should pass position" do
    @coordinate_helper.px.should == 123
    @coordinate_helper.py.should == 987
  end
end
