
require 'spec/rspec_helper'

describe StatLineMenuSelector do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @selections = Selections.new
    @selector = StatLineMenuSelector.new(@game)
  end

  it "should fetch elements" do
    @selections << hero("bob")
    elems = @selector.elements(@selections)
    names = elems.collect {|e| e.name }
    names.should == ["HP: 10/10", "MP: 1/1", "EXP: 0", "LVP: 0"]
  end

  it "should fetch an element" do
    @selections << hero("bob")
    elem = @selector.select_element_at(0, @selections)
    
    elem.should be_an_instance_of(StatLine)
    elem.name.should == "HP: 10/10"
  end
end
