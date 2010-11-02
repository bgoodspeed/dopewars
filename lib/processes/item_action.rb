
#TODO rename this to process
class ItemAction
  def initialize(action_cost=@@ITEM_ACTION_COST)
    @action_cost = action_cost
  end
  def perform(src, dest, item)
    raise "src cant be nil" if src.nil?
    raise "dest cant be nil" if dest.nil?
    raise "item cant be nil" if item.nil?
    
    src.consume_readiness(@action_cost)
    dest.consume_item(item)
  end
end
