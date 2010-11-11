
require 'spec/rspec_helper'

describe AttackBattleMenuAction do
  before(:each) do
    @action = AttackBattleMenuAction.new(@game)
  end

  it "should be described" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleReadyPartyMenuSelector, BattleTargetsMenuSelector]
  end
end
