
require 'spec/rspec_helper'

describe Inventory do
  before(:each) do
    @inventory = Inventory.new(200)
  end

  it "has a fixed number of slots" do
    @inventory.free_slots.should == 200
  end
end
