
require 'spec/rspec_helper'

describe UseSkillBattleMenuAction do
  before(:each) do
    @action = UseSkillBattleMenuAction.new(@game)
  end

  it "should be described" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleReadyPartyMenuSelector, BattleSkillMenuSelector, BattleTargetsMenuSelector]
  end
end
