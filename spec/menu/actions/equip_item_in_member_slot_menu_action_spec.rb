# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe EquipItemInMemberSlotMenuAction do
  before(:each) do
    @menu_action = EquipItemInMemberSlotMenuAction.new(nil)
  end

  it "should have a list of dependencies" do
    @menu_action.dependencies.size.should == 3
    @menu_action.dependencies[0].should be_an_instance_of PartyMenuSelector
    @menu_action.dependencies[1].should be_an_instance_of FilteredInventoryMenuSelector
    @menu_action.dependencies[2].should be_an_instance_of EquipmentSlotMenuSelector
  end
end

