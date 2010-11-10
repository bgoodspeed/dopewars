
require 'spec/rspec_helper'

describe ItemAction do
  include DomainMocks



  before(:each) do
    @src = mock_hero
    @dest = mock_hero
    @item = item("item")
    @item_action = ItemAction.new
  end

  it "should use items on perform" do
    expect_readiness_consumed(@src)
    expect_item_consumed(@dest, @item)
    @item_action.perform(@src, @dest, @item)
  end
end
