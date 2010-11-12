
require 'spec/rspec_helper'

describe BattleReadyPartyMenuSelector do
  include DomainMocks
  
  before(:each) do
    @game = mock_game
    @selector = BattleReadyPartyMenuSelector.new(@game)
  end

  it "should store elements" do
    stub_battle_ready_party_members(@selector.game, [:member1, :member2])
    @selector.elements.should == [:member1, :member2]
  end
end
