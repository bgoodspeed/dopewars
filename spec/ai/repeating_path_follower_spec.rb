# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe RepeatingPathFollower do
  before(:each) do
    @repeating_path_follower = RepeatingPathFollower.new("LURD", 2)
  end

  it "should be built with initial conditions" do
    
    @repeating_path_follower.ticks_per_path_unit.should == 2
    @repeating_path_follower.ticks_seen.should == 0
  end
  it "should be updatable - base case" do
    keys = AlwaysDownMonsterKeyHolder.new
    @repeating_path_follower.update(keys)
    @repeating_path_follower.ticks_seen.should == 1
    keys.size.should == 1
    @repeating_path_follower.path_idx.should == 0
  end
  it "should be updatable - rollover case" do
    keys = AlwaysDownMonsterKeyHolder.new
    @repeating_path_follower.update(keys)
    @repeating_path_follower.update(keys)
    @repeating_path_follower.ticks_seen.should == 0
    keys.size.should == 2 #TODO this is not quite right, should replace the other key -- doesn't really matter
    keys.should include(:up)
    @repeating_path_follower.path_idx.should == 1
    @repeating_path_follower.update(keys)
    @repeating_path_follower.update(keys)
    keys.size.should == 2 #TODO this is not quite right, should replace the other key -- doesn't really matter
    keys.should include(:right)

  end

  it "should be json ified" do
    @repeating_path_follower.json_params.should be_an_instance_of(Array)
  end
end

