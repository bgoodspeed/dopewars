
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
  it "should be able to toggle visibility" do #XXX is this notion actually different from activity?
    @layer.toggle_visibility
    @layer.visible.should be_true
  end
  it "should turn off once displayed" do
    @layer.toggle_activity
    @layer.displayed
    @layer.active.should be_false
  end

  it "should draw via blit ops" do
    surf = expect_render(@layer.font)
    expect_blitted(surf)
    expect_blitted(@layer.layer)
    @layer.draw
  end
end
