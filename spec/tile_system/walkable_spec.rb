
require 'spec/rspec_helper'

describe Walkable do
  before(:each) do
    @walkable = Walkable.new
  end

  it "should not block" do
    @walkable.is_blocking?.should be_false
  end
end
