
require 'spec/rspec_helper'

describe Notification do
 before(:each) do
    @notification = Notification.new("foo", 125, nil)
  end

  it "starts alive" do
    @notification.dead?.should be_false
  end
  it "should hold message" do
    @notification.message.should == "foo"
  end
  it "should hold time to live" do
    @notification.time_to_live.should == 125
  end
  it "should decrement time to live on display" do
    @notification.displayed
    @notification.time_to_live.should == 124
  end
  it "should know how if it has been displayed long enough" do
    @notification.time_to_live.times { @notification.displayed }
    @notification.dead?.should be_true
  end
end
