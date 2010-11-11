
require 'spec/rspec_helper'

describe EquipmentSlotMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selections = Selections.new
    @selector = EquipmentSlotMenuSelector.new(@game)
  end

  it "should fetch elements" do
    @selections << hero("bob")
    #TODO not yet implemented
#    elems = @selector.elements(@selections)
#    names = elems.collect {|e| e.name }
#    names.should == ["HP: 10/10", "MP: 1/1", "EXP: 0", "LVP: 0"]
  end
end
