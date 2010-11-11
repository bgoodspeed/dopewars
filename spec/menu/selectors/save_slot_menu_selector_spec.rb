
require 'spec/rspec_helper'

describe SaveSlotMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selections = Selections.new
    @selector = SaveSlotMenuSelector.new(@game)
  end

  it "should fetch elements" do
    elems = @selector.elements(@selections)
    names = elems.collect {|e| e.name }
    names.should == ["Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6"]
  end
end
