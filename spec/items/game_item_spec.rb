
require 'spec/rspec_helper'

describe GameItem do
  before(:each) do
    @item = GameItemFactory.antidote
  end

  it "should be consumeable or not" do
    @item.consumeable?.should be_true
    GameItemFactory.sword.consumeable?.should be_false
  end

  it "should not be equippable" do
    @item.equippable?.should be_false
  end

  it "should store the name" do
    GameItemFactory.sword.to_s.should == "sword"
    GameItemFactory.potion.to_s.should == "potion"
  end


end
