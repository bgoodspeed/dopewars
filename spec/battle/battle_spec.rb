# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe Battle do
  include DomainMocks



  before(:each) do
    p = mock_player
    u = mock_universe
    u.stub!(:x_offset_for_world).and_return 0
    u.stub!(:y_offset_for_world).and_return 0
    u.stub!(:x_offset_for_interaction).and_return 0
    u.stub!(:y_offset_for_interaction).and_return 0
    @battle = Battle.new(mock_game, monster(p,u))
  end

  it "be able to find heroes by name" do
    @battle.hero_by_name("ALPHA").name.should == "ALPHA"
    @battle.hero_by_name("BETA").name.should == "BETA"
    @battle.hero_by_name("monkeyman").should be_nil
  end
  it "be able to find the first monster" do
    @battle.first_monster.should be_an_instance_of Monster
  end

  it "should accumulate readiness" do
    expect_add_readiness(@battle.player)
    @battle.monsters.each {|actor| expect_add_readiness(actor)}
    @battle.accumulate_readiness(3)
  end

  it "should consider both heroes and monsters to be participants" do
    @battle.participants.size.should == 3
    @battle.current_battle_participant(0).class.should == Monster
    @battle.current_battle_participant(1).class.should == Hero
    @battle.current_battle_participant(2).class.should == Hero
  end

  it "should calculate offsets for an index" do
    @battle.participants.size.should == 3
    @battle.current_battle_participant_offset(0).should == [15,15]
    @battle.current_battle_participant_offset(1).should == [15,400]
    @battle.current_battle_participant_offset(2).should == [80, 400]
  end
end

