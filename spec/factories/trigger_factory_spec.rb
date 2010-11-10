
require 'spec/rspec_helper'

describe TriggerFactory do
  before(:each) do
    @trigger_factory = TriggerFactory.new
  end

  

  it "should make tick trigger" do
    @trigger_factory.make_tick_trigger.should be_an_instance_of(TickTriggerFacade)
  end
  it "should make any key press trigger" do
    @trigger_factory.make_any_key_press_trigger.should be_an_instance_of(KeyPressTriggerFacade)
  end
  it "should make any key press trigger" do
    @trigger_factory.make_key_press_trigger(:left).should be_an_instance_of(KeyPressTriggerFacade)
  end
  it "should make key release trigger" do
    @trigger_factory.make_key_release_trigger.should be_an_instance_of(KeyReleaseTriggerFacade)
  end

  
  it "should make event handler" do
    @trigger_factory.make_event_handler.should be_an_instance_of(EventHandlerFacade)
  end
  it "should make event hook" do
    @trigger_factory.make_event_hook(:owner, :key_press, :do_foo_action).should be_an_instance_of(EventHookFacade)
  end
  it "should make event hook" do
    @trigger_factory.make_key_press_event_hook(:owner, :key, :do_other_foo).should be_an_instance_of(EventHookFacade)
  end
  it "should make " do
    @trigger_factory.make_method_action(:do_foo).should be_an_instance_of(MethodActionFacade)
  end

end
