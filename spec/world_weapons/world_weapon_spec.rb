
require 'spec/rspec_helper'

describe WorldWeapon do
  before(:each) do
    @world_weapon = WorldWeapon.new(nil)
  end

  it "should store ticks displayed" do
    @world_weapon.ticks.should == 0
  end
  it "should increment ticks displayed" do
    @world_weapon.displayed
    @world_weapon.ticks.should == 1
  end
  it "should know when it is consumed - starts unconsumed" do
    @world_weapon.consumed?.should be_false
  end
  it "should know when it is consumed" do
    @world_weapon.max_ticks.times { @world_weapon.displayed}
    @world_weapon.consumed?.should be_true
  end
  it "should be able to die" do
    @world_weapon.displayed
    @world_weapon.die
    @world_weapon.ticks.should == 0
  end

  it "should respond to draw weapon" do
    @world_weapon.respond_to?(:draw_weapon).should be_true
  end
end
