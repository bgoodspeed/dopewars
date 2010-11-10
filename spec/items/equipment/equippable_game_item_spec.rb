
require 'spec/rspec_helper'

describe EquippableGameItem do
  before(:each) do
    @item = EquippableGameItem.new("foo", nil)
  end

  it "should not be consumable" do
    @item.consumeable?.should be_false
  end
end
