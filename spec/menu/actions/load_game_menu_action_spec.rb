# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe LoadGameMenuAction do
  before(:each) do
    @menu_action = LoadGameMenuAction.new(nil)
  end

  it "should have a list of dependencies" do
    @menu_action.dependencies.size.should == 1
    @menu_action.dependencies[0].should be_an_instance_of SaveSlotMenuSelector
  end
end

