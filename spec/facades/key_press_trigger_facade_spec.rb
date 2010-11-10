
require 'spec/rspec_helper'

describe KeyPressTriggerFacade do
  include DomainMocks
  before(:each) do
    @event = mock_event
    @key_press_trigger_facade = KeyPressTriggerFacade.new
  end

  it "should match key presses" do
    @key_press_trigger_facade.match?(@event).should be_false
  end
end
