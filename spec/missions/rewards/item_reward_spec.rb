
require 'spec/rspec_helper'

describe ItemReward do
  include DomainMocks


  before(:each) do
    @game = mock_game
    @item = mock_item
    @reward = ItemReward.new(@game, @item)
  end

  it "should be described" do
    #TODO unimplemented
  end
end
