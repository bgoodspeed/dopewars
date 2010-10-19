
#TODO rename this to process
class ItemAction
  def initialize(action_cost=@@ITEM_ACTION_COST)
    @action_cost = action_cost
  end
  def perform(src, dest, item)
    dest.consume_item(item)
    src.consume_readiness(@action_cost)
  end
end
