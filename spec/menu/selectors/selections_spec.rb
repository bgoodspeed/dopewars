# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe Selections do
  before(:each) do
    @selections = Selections.new
  end

  it "should be able to drop the last selection" do
    @selections << Hero.new
    @selections << "monkeys"
    @selections.drop_last
    @selections.first.should be_an_instance_of Hero
    @selections.size.should == 1
  end

  it "should be able to tell if it satisfies a selector" do
    @selections.satisfy?(PartyMenuSelector.new(nil)).should be_false
    @selections << Hero.new
    @selections.satisfy?(PartyMenuSelector.new(nil)).should be_true
  end

  it "should be able to find party members" do
  end

  it "should be able to find inventory items" do
    
  end
end

