# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe PartyMenuSelector do
  include DomainMocks

  include MenuSelectorMatchers

  before(:each) do
    @menu_selector = PartyMenuSelector.new(mock_game)
  end


  it "is a menu selector" do
    @menu_selector.should behave_as_a_menu_selector
  end

  it "meets the criteria of a menu selector -- elements" do
    @menu_selector.size.should be_a_kind_of Numeric
  end
  it "meets the criteria of a menu selector -- elements" do
    @menu_selector.elements(nil).should be_an_instance_of Array
  end
  
  it "meets the criteria of a menu selector -- selection type" do
    @menu_selector.selection_type.should be_an_instance_of Class
  end

  it "should desc" do
    # TODO
  end
end

