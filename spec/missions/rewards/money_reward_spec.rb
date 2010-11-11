
require 'spec/rspec_helper'

describe MoneyReward do
  include DomainMocks


  before(:each) do
    @game = mock_game
    @reward = MoneyReward.new(@game, 300)
  end

  it "should be described" do
    #TODO unimplemented
  end
end
