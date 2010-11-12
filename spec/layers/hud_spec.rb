
require 'spec/rspec_helper'

describe Hud do
  include DomainMocks
  include MethodDefinitionMatchers
  before(:each) do
    @hud = Hud.new({:player => mock_player, :screen => mock_screen})
  end

  it "should define draw" do
    @hud.should define(:draw)
  end
  it "should define update" do
    @hud.should define(:update)
  end

  it "should be updatable" do
    stub_inventory_count(@hud.player, 42)

    @hud.update({:time => :foo})
    @hud.time.should == "foo, Items collected: 42"
  end

  it "should draw by rendering the font and bliting" do
    surf = expect_render(@hud.font)
    expect_blitted(surf)
    @hud.draw
  end
end
