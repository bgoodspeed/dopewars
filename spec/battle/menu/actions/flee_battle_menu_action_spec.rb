
require 'spec/rspec_helper'

describe FleeBattleMenuAction do
  before(:each) do
    @action = FleeBattleMenuAction.new(@game)
  end

  it "should be described" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleReadyPartyMenuSelector, BattleTargetsMenuSelector]
  end
end
