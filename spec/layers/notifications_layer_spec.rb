
require 'spec/rspec_helper'

describe NotificationsLayer do
  include DomainMocks

  before(:each) do
    @screen = mock_screen
    @game = mock_game
    @layer = NotificationsLayer.new(@screen, @game)
  end

  def notification
    Notification.new("herro", 3, :foo)
  end

  it "should be able to add notifications" do
    @layer.notifications.should == []
    n = notification
    @layer.add_notification(n)
    @layer.notifications.should == [n]
  end

  it "should built its own config" do
    @layer.config_for(0).should be_an_instance_of(TextRenderingConfig)
  end

  it "should be able to draw" do
    n = notification
    @layer.add_notification(n)

    expect_blitted(@layer.layer)
    n.time_to_live.should == 3
    @layer.draw
    n.time_to_live.should == 2
  end
end
