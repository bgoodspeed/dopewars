# To change this template, choose Tools | Templates
# and open the template in the editor.

class TriggerFactory
  def initialize
    
  end
  def make_event_handler
    EventHandlerFacade.new
  end
  def make_tick_trigger
    TickTriggerFacade.new
  end
  def make_any_key_press_trigger
    KeyPressTriggerFacade.new
  end
  def make_key_press_trigger(key)
    KeyPressTriggerFacade.new(key)
  end
  def make_key_release_trigger
    KeyReleaseTriggerFacade.new
  end

  def make_method_action(target)
    MethodActionFacade.new(target)
  end

  def map_trigger_type(trigger_type)
    conf = {}
    conf[:tick] = make_tick_trigger
    conf[:key_press] = make_any_key_press_trigger
    conf[:key_release] = make_key_release_trigger

    conf[trigger_type]
  end

  def make_event_hook(owner, trigger_type, action_target)
    EventHookFacade.new(:owner => owner, :trigger => map_trigger_type(trigger_type), :action => make_method_action(action_target) )
  end
  def make_key_press_event_hook(owner, key, action_target)
    EventHookFacade.new(:owner => owner, :trigger => make_key_press_trigger(key), :action => make_method_action(action_target) )
  end
end
