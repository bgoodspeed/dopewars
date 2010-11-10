
require 'spec/rspec_helper'

describe BattleLayer do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @screen = mock_screen
    @layer = BattleLayer.new(@screen, @game)
  end

  it "should start out inactive" do
    @layer.active.should be_false
  end
  it "should start out without a battle" do
    @layer.battle.should be_nil
  end
  
  it "should start fights " do
    @layer.start_battle(@game, @monster)
    @layer.battle.should_not be_nil
    @layer.active.should be_true
  end
end
