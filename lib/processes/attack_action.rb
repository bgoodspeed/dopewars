

#TODO rename this to process
class AttackAction
  def initialize(action_cost=@@ATTACK_ACTION_COST)
    @action_cost = action_cost
  end
  def perform(src, dest)
    dest.take_damage(DamageCalculationHelper.new.calculate_damage(src, dest))
    src.consume_readiness(@action_cost)
  end
end