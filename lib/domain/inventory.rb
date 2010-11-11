# To change this template, choose Tools | Templates
# and open the template in the editor.

class InsufficientItemsToRemoveException < Exception

end

class InventoryItem
  extend Forwardable
  def_delegators :item, :effects, :name

  attr_accessor :quantity, :item
  def initialize(quantity, item)
    @quantity = quantity
    @item = item
  end

  def to_info
    "#{@item} : #{@quantity}"
  end

  def consumed
    @quantity -= 1
  end


  include JsonHelper
  def json_params
    [ @quantity, @item ]
  end

end

class Inventory
  def initialize(max_slots, items={})
    @max_slots = max_slots
    @items = items
    
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

  def inventory_info #TODO this should respect sort orders
    keys.collect {|key| @items[key]}
  end

  def inventory_item_at(idx)
    inventory_info[idx]
  end

  def gain_inventory(inventory)
    inventory.keys.each do |key|
      add_item(inventory.quantity_of(key), key)
    end
  end

  def remove_item(quantity, item)
    raise InsufficientItemsToRemoveException unless quantity_of(item) >= quantity
    @items[item].quantity -= quantity
    
  end
  def has_item?(item)
    !@items[item].nil?
  end

  def size
    keys.size
  end

  def inventory_count
    rv = 0
    @items.each {|k,v|
      rv += v.quantity
    }
    rv
  end
  def quantity_of(item)
    return 0 unless has_item?(item)
    @items[item].quantity
  end


  include JsonHelper
  def json_params
    [ @max_slots, @items ]
  end


end
