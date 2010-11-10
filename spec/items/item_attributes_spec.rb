
require 'spec/rspec_helper'

describe ItemAttributes do
  before(:each) do
    @attributes = ItemAttributes.new(10,9,8,7,6,5,4,3)
  end

  it "should bind attributes from constructor" do
    @attributes.agility.should == 4
  end
end
