
require 'spec/rspec_helper'

describe GameItem do
  before(:each) do
    @item = GameItemFactory.antidote
  end

  it "should be consumeable or not" do
    @item.consumeable?.should be_true
    GameItemFactory.sword.consumeable?.should be_false
  end
end
