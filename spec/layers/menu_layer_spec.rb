
require 'spec/rspec_helper'

describe MenuLayer do
  include DomainMocks
  include MethodDefinitionMatchers
  
  before(:each) do
    @screen = mock_screen
    @game = mock_game
    @layer = MenuLayer.new(@screen, @game)
  end

  it "should be inactive by default" do
    @layer.active.should be_false
  end

  it "should define menu api" do
    @layer.should define(:move_cursor_up)
    @layer.should define(:move_cursor_down)
    @layer.should define(:enter_current_cursor_location)
  end
end
