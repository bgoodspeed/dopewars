
require 'spec/rspec_helper'

describe Hero do
  include DomainMocks
  
  before(:each) do
    @hero = hero("bob")
  end

  it "should have a name" do
    @hero.name.should == "bob"
  end
end
