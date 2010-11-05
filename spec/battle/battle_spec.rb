# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe Battle do
  include DomainMocks



  before(:each) do
    p = mock_player
    u = mock_universe
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
end

