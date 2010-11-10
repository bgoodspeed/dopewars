
require 'spec/rspec_helper'

describe ShotWorldWeapon do
  include DomainMocks
  
  before(:each) do
    @shot_world_weapon = ShotWorldWeapon.new(nil)
  end

  it "should store ticks displayed" do
    @shot_world_weapon.ticks.should == 0
  end
  it "should increment ticks displayed" do
    @shot_world_weapon.displayed
    @shot_world_weapon.ticks.should == 1
  end
  it "should know when it is consumed - starts unconsumed" do
    @shot_world_weapon.consumed?.should be_false
  end
  it "should know when it is consumed" do
    @shot_world_weapon.max_ticks.times { @shot_world_weapon.displayed}
    @shot_world_weapon.consumed?.should be_true
  end
  it "should be able to die" do
    @shot_world_weapon.displayed
    @shot_world_weapon.die
    @shot_world_weapon.ticks.should == 0
  end

  it "should respond to draw weapon" do
    @shot_world_weapon.respond_to?(:draw_weapon).should be_true
  end


end
