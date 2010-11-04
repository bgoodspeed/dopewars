# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe MissionInfoMenuAction do
  include DomainMocks
  before(:each) do
    @menu_action = MissionInfoMenuAction.new(mock_game)
  end

  it "should meet the requirements of a menu action -- dependencies" do
    @menu_action.dependencies.should be_an_instance_of Array
  end
  it "should meet the requirements of a menu action -- name" do
    @menu_action.name.should be_an_instance_of String
  end
end

