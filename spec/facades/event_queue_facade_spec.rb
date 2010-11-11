
require 'spec/rspec_helper'

describe EventQueueFacade do
  before(:each) do
    @event_queue_facade = EventQueueFacade.new
  end

  it "should start empty" do
    @event_queue_facade.should == []
  end
  
  it "should grow" do
    @event_queue_facade << "foo"
    @event_queue_facade.should == ["foo"]
  end

  it "should ignore mouse events" do
    @event_queue_facade.ignore.size.should == 0
    @event_queue_facade.ignore_mouse_movement
    @event_queue_facade.ignore.size.should == 1
  end
end
