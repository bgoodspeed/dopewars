
require 'spec/rspec_helper'

describe Pallette do
  before(:each) do
    @pallette = Pallette.new(:foo)
  end

  it "should get values" do
    @pallette[0].should == :foo
  end
end
