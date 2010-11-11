
require 'spec/rspec_helper'

describe AcceptBattleOutcomeMenuAction do
  before(:each) do
    @action = AcceptBattleOutcomeMenuAction.new(@game)
  end

  it "should be described" do
    klasses = @action.dependencies.collect {|dep| dep.class}
    klasses.should == [BattleAcceptSpoilsMenuSelector]
  end
end
