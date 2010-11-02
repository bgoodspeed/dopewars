# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe LevelUpStatMenuAction do
  before(:each) do
    @menu_action = LevelUpStatMenuAction.new(nil)
  end

  it "should have a list of dependencies" do
    @menu_action.dependencies.size.should == 2
    @menu_action.dependencies[0].should be_an_instance_of PartyMenuSelector
    @menu_action.dependencies[1].should be_an_instance_of StatLineMenuSelector
  end
end

