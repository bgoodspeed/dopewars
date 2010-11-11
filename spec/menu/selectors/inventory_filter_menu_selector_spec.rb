
require 'spec/rspec_helper'

describe InventoryFilterMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selections = Selections.new
    @selector = InventoryFilterMenuSelector.new(@game)
  end

  it "should fetch elements" do
    elems = @selector.elements(@selections)
    names = elems.collect {|e| e.name }
    names.should == ["All Items", "Key Items"]
  end
end
