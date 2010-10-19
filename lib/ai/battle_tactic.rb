class BattleTactic
  extend Forwardable
  def_delegators :@action, :perform_on

  attr_accessor :target, :condition, :action
  def initialize(desc)
    parse(desc)
  end

  def parse(desc)
    target_and_rest = desc.split(":")
    cond_and_act = target_and_rest[1].split("->")
    @target = TargetMatcher.new(target_and_rest[0])
    @condition = ConditionMatcher.new(cond_and_act[0])
    @action = ActionInvoker.new(cond_and_act[1])
  end

  def matches?(source, target)
    @target.matches?(source, target) and @condition.matches?(source, target)
  end

end
