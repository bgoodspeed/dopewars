

#TODO rename to process
class ActionInvoker
  attr_accessor :action
  def initialize(action_desc)
    @action = build_from(action_desc)
  end

  def build_from(action_desc)
    return AttackAction.new if action_desc.downcase.include?("attack")
  end

  def perform_on(src, dest)
    @action.perform(src,dest)
  end
end
