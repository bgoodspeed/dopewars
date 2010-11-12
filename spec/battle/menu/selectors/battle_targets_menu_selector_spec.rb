
require 'spec/rspec_helper'

describe BattleTargetsMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selector = BattleTargetsMenuSelector.new(@game)
  end

  it "should store elements" do
    stub_battle_members(@selector.game, [:member1, :member2])
    @selector.elements(nil).should == [:member1, :member2]
  end
end
