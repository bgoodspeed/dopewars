
require 'spec/rspec_helper'

describe BattleMenuAction do
  before(:each) do
    @action = BattleMenuAction.new(@game, "battlename", [])
  end

  it "should add selector deps implicitly" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleReadyPartyMenuSelector,  BattleTargetsMenuSelector]
  end
end
