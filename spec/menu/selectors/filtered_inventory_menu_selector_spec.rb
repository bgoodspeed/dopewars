
require 'spec/rspec_helper'

describe FilteredInventoryMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selections = Selections.new
    @selector = FilteredInventoryMenuSelector.new(@game)
  end

  it "should filter elements using selections" do
    elems = @selector.elements(@selections)
    names = elems.collect {|e| e.name }
    names.should == ["item 1"]
  end

  it "should be able to select an element at an index" do
    @selector.select_element_at(0, @selections)
  end

  
end
