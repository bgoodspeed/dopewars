
require 'spec/rspec_helper'

describe SwungWorldWeapon do
  include DomainMocks

  before(:each) do
    @screen = mock_screen
    @surface = mock_surface
    @pallette = Pallette.new(@surface)
    @weapon = SwungWorldWeapon.new(@pallette)
  end


 
  it "should store ticks displayed" do
    @weapon.ticks.should == 0
  end
  it "should increment ticks displayed" do
    @weapon.displayed
    @weapon.ticks.should == 1
  end
  it "should know when it is consumed - starts unconsumed" do
    @weapon.consumed?.should be_false
  end
  it "should know when it is consumed" do
    @weapon.max_ticks.times { @weapon.displayed}
    @weapon.consumed?.should be_true
  end
  it "should be able to die" do
    @weapon.displayed
    @weapon.die
    @weapon.ticks.should == 0
  end

  it "should respond to draw weapon" do
    @weapon.respond_to?(:draw_weapon).should be_true
  end

  it "should have a screen config for facing dirs" do
    @weapon.screen_config[:up][:screen].should be_an_instance_of Array
    @weapon.screen_config[:up][:rotate].should be_a_kind_of Numeric
  end

  it "should calculate screen config for facing dirs" do
    @weapon.screen_offsets_for(:up).should be_an_instance_of Array
  end
  it "should calculate effective offsets" do
    @weapon.effective_offsets(@screen, :up).should == [305, 195]
  end

  it "should be able to draw by blits" do
    expect_rotozoom(@surface)
    expect_colorkey_set(@surface)
    expect_blitted(@surface)
    @weapon.facing = :up
    @weapon.draw_weapon(@screen)
  end


end
