# To change this template, choose Tools | Templates
# and open the template in the editor.

class InsufficientItemsToRemoveException < Exception

end

class InventoryItem
  attr_accessor :quantity, :item
  def initialize(quantity, item)
    @quantity = quantity
    @item = item
  end
end

class Inventory
  def initialize(max_slots)
    @max_slots = max_slots
    @items = {}
    
  end

  def keys
    @items.keys
  end

  def free_slots
    @max_slots - @items.keys.size
  end

  def add_item(quantity, item)
    if (has_item?(item))
      @items[item].quantity += quantity
    else
      @items[item] = InventoryItem.new(quantity, item)
    end
  end

  def remove_item(quantity, item)
    raise InsufficientItemsToRemoveException unless quantity_of(item) >= quantity
    @items[item].quantity -= quantity
    
  end
  def has_item?(item)
    !@items[item].nil?
  end

  def quantity_of(item)
    return 0 unless has_item?(item)
    @items[item].quantity
  end
end
