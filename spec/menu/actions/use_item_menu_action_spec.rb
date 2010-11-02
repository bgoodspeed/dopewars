# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe UseItemMenuAction do
  def hero(name)
    h = Hero.new(name,nil, 1, 1, CharacterAttribution.new(CharacterState.new(CharacterAttributes.new(0,1,2,3,4,5,6,7)), nil))
    h
  end

  def item(name)
    i = InventoryItem.new(1, GameItem.new(name, ItemState.new(ItemAttributes.none)))
    i
  end

  def mock_game
    g = mock("game")
    g.stub!(:party_members).and_return([hero("person a"), hero("person b")])
    g.stub!(:inventory_info).and_return([item("item 1")])
    g
  end



  before(:each) do
    @menu_action = UseItemMenuAction.new(mock_game)
  end

  it "should have a list of dependencies" do
    @menu_action.dependencies.size.should == 3
    @menu_action.dependencies[0].should be_an_instance_of InventoryFilterMenuSelector
    @menu_action.dependencies[1].should be_an_instance_of FilteredInventoryMenuSelector
    @menu_action.dependencies[2].should be_an_instance_of PartyMenuSelector
  end
end

