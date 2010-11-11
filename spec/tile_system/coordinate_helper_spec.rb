
require 'spec/rspec_helper'

describe CoordinateHelper do
  include DomainMocks

  before(:each) do
    posn_coords = SdlCoordinate.new(123, 987)
    dim_coords = SdlCoordinate.new(33, 44)
    posn = PositionedTileCoordinate.new(posn_coords, dim_coords)
    @universe = mock_universe
    @keys = KeyHolder.new
    @coordinate_helper = CoordinateHelper.new(posn, @keys, @universe)
  end

  it "should pass position" do
    @coordinate_helper.px.should == 123
    @coordinate_helper.py.should == 987
  end

  it "should update position " do
    @coordinate_helper.update_pos(0.02)
    @coordinate_helper.px.should == 123
    @coordinate_helper.py.should == 938
  end

  it "should update velocity" do
    @coordinate_helper.update_vel(0.02)
    @coordinate_helper.vx.should == 0.0
    @coordinate_helper.vy.should == 0.0
  end

  it "should update velocity -- down pressed" do
    @keys.add_key(:down)
    @coordinate_helper.update_accel
    @coordinate_helper.update_vel(0.02)
    @coordinate_helper.vx.should == 0.0
    @coordinate_helper.vy.should == 24.0
  end

  it "can get position" do
    @coordinate_helper.get_position.should == [123, 987]
  end

  it "knows how to slow down" do
    @coordinate_helper.update_vel_axis(5, 0, 0.1).should == 0.0
    @coordinate_helper.update_vel_axis(-5, 0, 0.1).should == 0.0
  end
  it "should update accel -- no keys" do
    @coordinate_helper.update_accel
    @coordinate_helper.ax.should == 0
    @coordinate_helper.ay.should == 0
  end
  it "should update accel -- down" do
    @keys.add_key(:down)
    @coordinate_helper.update_accel
    @coordinate_helper.ax.should == 0
    @coordinate_helper.ay.should == 1200
  end

  it "should clamp to world dims if we hit a corner" do
    @coordinate_helper.check_corners(mock_no_walking_interpreter, 1,2,3,4).should be_true
    @coordinate_helper.check_corners(mock_interpreter, 1,2,3,4).should be_false
  end

  it "should find blocking npcs" do
    not_blocking = mock_blocking(false)
    blocking = mock_blocking
    @coordinate_helper.blocking([not_blocking, blocking]).should == [blocking]
  end

  it "should find hit npcs" do
    not_colliding = mock_colliding(false)
    colliding = mock_colliding
    @coordinate_helper.hits([not_colliding, colliding]).should == [colliding]
  end

  it "can tell if something collides - x" do
    @coordinate_helper.collides_on_x?(123).should be_true
    @coordinate_helper.collides_on_x?(999).should be_false
  end

  it "can tell if something collides - y" do
    @coordinate_helper.collides_on_y?(987).should be_true
    @coordinate_helper.collides_on_y?(111).should be_false
  end

  it "should handle collisions - none" do
    @coordinate_helper.handle_collision([])
  end
  it "should handle collisions - one" do
    mon = monster(@player, @universe)
    mon.should_receive(:interact)
    @coordinate_helper.handle_collision([mon])
  end
end
