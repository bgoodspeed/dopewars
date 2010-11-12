
require 'spec/rspec_helper'

describe CharacterAttributes do
  before(:each) do
    @character_attributes = CharacterAttributes.new(10,9,8,7,6,5,4,3)
    @other_attributes = CharacterAttributes.new(1,1,1,1,1,1,1,1)
  end

  it "should bind attributes from constructor" do
    @character_attributes.agility.should == 4
    @character_attributes.luck.should == 3
  end
  it "should add attributes" do
    @character_attributes.add_attributes(@other_attributes)
    @character_attributes.agility.should == 5
    @character_attributes.luck.should == 4
  end

  it "should be json ified" do
    @character_attributes.json_params.should be_an_instance_of(Array)
  end
end
