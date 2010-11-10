
require 'spec/rspec_helper'

describe TickTriggerFacade do
  include DomainMocks

  before(:each) do
    @tick_trigger_facade = TickTriggerFacade.new
  end

  it "should match events" do
    @tick_trigger_facade.match?(mock_event).should be_false
  end
end
