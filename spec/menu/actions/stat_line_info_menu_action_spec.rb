# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe StatLineInfoMenuAction do
  include DomainMocks

  before(:each) do
    @selections = Selections.new
    @menu_action = StatLineInfoMenuAction.new(mock_game)
  end

  it "should support path navigation" do
    @menu_action.navigate_path([]).should be_an_instance_of PartyMenuSelector
    @menu_action.navigate_path([0]).should be_an_instance_of StatLineMenuSelector
  end

  it "should have a list of dependencies" do
    @menu_action.dependencies.size.should == 2
    @menu_action.dependencies[0].should be_an_instance_of PartyMenuSelector
    @menu_action.dependencies[1].should be_an_instance_of StatLineMenuSelector
  end

  it "should be able to tell if it is satisfied by a set of selections" do
    @menu_action.satisfied_by?(@selections).should be_false
    @selections << Hero.new
    @menu_action.satisfied_by?(@selections).should be_false
    @selections << StatLine.new("foo")
    @menu_action.satisfied_by?(@selections).should be_true
  end

  it "should be able to tell if selected and satisfied" do
    @menu_action.selected_and_satisfied_by?(@selections).should be_false
    @selections << @menu_action
    @selections << Hero.new
    @selections << StatLine.new("foo")
    @menu_action.selected_and_satisfied_by?(@selections).should be_true
  end

  it "should be able to tell if it has been selected" do
    @menu_action.selection_match?(@selections).should be_false
    @selections << @menu_action
    @menu_action.selection_match?(@selections).should be_true
  end

  it "should be able to navigate to selectable things" do
    @menu_action.navigate_path_to_select([0], @selections).should be_an_instance_of Hero
    @selections << hero("bob")
    @menu_action.navigate_path_to_select([0,0], @selections).should be_an_instance_of StatLine
  end

end

