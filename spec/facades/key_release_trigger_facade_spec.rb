
require 'spec/rspec_helper'

#TODO these facades are hard to test, must investigate the rubygame model to see how they are used
describe KeyReleaseTriggerFacade do
  include DomainMocks
  
  before(:each) do
    @key_release_trigger_facade = KeyReleaseTriggerFacade.new
  end

  it "should be described" do
    @key_release_trigger_facade.match?(mock_event).should be_false
  end
end
