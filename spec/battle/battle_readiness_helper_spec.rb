
require 'spec/rspec_helper'

describe BattleReadinessHelper do
  before(:each) do
    @helper = BattleReadinessHelper.new(10, 5)
  end

  it "should start off with starting points" do
    @helper.points.should == 10
  end
  it "should grow by growth rate" do
    @helper.add_readiness(1)
    @helper.points.should == 15

  end
  it "should consume readiness" do
    @helper.consume_readiness(7)
    @helper.points.should == 3
  end

  it "should know when it is ready" do
    @helper.ready?.should be_false
    @helper.add_readiness(1000)
    @helper.ready?.should be_true
  end

end
