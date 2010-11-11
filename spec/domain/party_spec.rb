
require 'spec/rspec_helper'

describe Party do
  before(:each) do
    @party = Party.new([@hero1, @hero2], @inventory)
  end

  it "should have a leader" do
    @party.leader.should == @hero1
  end
end
