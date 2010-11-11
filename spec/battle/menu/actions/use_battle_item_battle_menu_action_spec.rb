
require 'spec/rspec_helper'

describe UseBattleItemBattleMenuAction do
  before(:each) do
    @action = UseBattleItemBattleMenuAction.new(@game)
  end

  it "should be described" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleReadyPartyMenuSelector, BattleFilteredInventoryMenuSelector, BattleTargetsMenuSelector]
  end
end
