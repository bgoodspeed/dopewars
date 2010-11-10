
require 'spec/rspec_helper'

describe EventHandlerFacade do
  before(:each) do
    @event_handler_facade = EventHandlerFacade.new
  end

  it "should hold hooks" do
    @event_handler_facade.hooks.should == []
  end
end
