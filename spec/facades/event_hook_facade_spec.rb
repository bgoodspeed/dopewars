
require 'spec/rspec_helper'

describe EventHookFacade do
  before(:each) do
    @event_hook_facade = EventHookFacade.new

  end

  it "should support event hook binds" do
    @event_hook_facade.action = "foo"
  end
end
