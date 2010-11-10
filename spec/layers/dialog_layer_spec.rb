
require 'spec/rspec_helper'

describe DialogLayer do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @screen = mock_screen
    @layer = DialogLayer.new(@screen, @game)
  end

  it "should start out inactive" do
    @layer.active.should be_false
  end

  it "should be able to toggle activity" do
    @layer.toggle_activity
    @layer.active.should be_true
  end
end
