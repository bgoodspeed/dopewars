
require 'spec/rspec_helper'

describe CharacterAttributes do
  before(:each) do
    @character_attributes = CharacterAttributes.new(10,9,8,7,6,5,4,3)
  end

  it "should bind attributes from constructor" do
    @character_attributes.agility.should == 4
  end
end
