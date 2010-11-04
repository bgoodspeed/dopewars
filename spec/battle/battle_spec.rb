# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe Battle do
  include DomainMocks

  def mock_party
    m = mock("party")
    m.stub!(:members).and_return [named_mock("ALPHA"), named_mock("BETA")]
    m
  end

  def mock_player
    m = mock("player")
    m.stub!(:party).and_return mock_party
    m
  end

  def mock_layer
    m = mock("layer")
    m
  end

  def mock_world
    m = mock("world")
    m.stub!(:x_offset_for_world).and_return 42
    m.stub!(:y_offset_for_world).and_return 69
    m.stub!(:x_offset_for_interaction).and_return 42
    m.stub!(:y_offset_for_interaction).and_return 69
    m
  end

  def mock_universe
    m = mock("universe")
    m.stub!(:current_world).and_return mock_world
    m
  end



  before(:each) do
    p = mock_player
    u = mock_universe
    @battle = Battle.new(mock_game, u, p, monster(p,u), mock_layer)
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

