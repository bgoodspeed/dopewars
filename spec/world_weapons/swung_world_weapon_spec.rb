
require 'spec/rspec_helper'

describe SwungWorldWeapon do
  include DomainMocks

  before(:each) do
    @swung_world_weapon = SwungWorldWeapon.new(nil)
  end


 
  it "should store ticks displayed" do
    @swung_world_weapon.ticks.should == 0
  end
  it "should increment ticks displayed" do
    @swung_world_weapon.displayed
    @swung_world_weapon.ticks.should == 1
  end
  it "should know when it is consumed - starts unconsumed" do
    @swung_world_weapon.consumed?.should be_false
  end
  it "should know when it is consumed" do
    @swung_world_weapon.max_ticks.times { @swung_world_weapon.displayed}
    @swung_world_weapon.consumed?.should be_true
  end
  it "should be able to die" do
    @swung_world_weapon.displayed
    @swung_world_weapon.die
    @swung_world_weapon.ticks.should == 0
  end

  it "should respond to draw weapon" do
    @swung_world_weapon.respond_to?(:draw_weapon).should be_true
  end
end
