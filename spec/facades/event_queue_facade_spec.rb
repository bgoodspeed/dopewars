
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
end
