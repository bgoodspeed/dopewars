
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
end
