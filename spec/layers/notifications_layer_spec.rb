
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
end
