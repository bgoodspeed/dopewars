# To change this template, choose Tools | Templates
# and open the template in the editor.

class InsufficientItemsToRemoveException < Exception

end

class InventoryItem
  extend Forwardable
  def_delegators :item, :effects

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

  def to_json(*a)
   {
      'json_class' => self.class.name,
      'data' => [ @quantity, @item ]
    }.to_json(*a)

  end
  def self.json_create(o)
    new(*o['data'])
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

  def gain_inventory(inventory)
    inventory.keys.each do |key|
      puts "key: #{key}"
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

  def quantity_of(item)
    return 0 unless has_item?(item)
    @items[item].quantity
  end

  def to_json(*a)
   {
      'json_class' => self.class.name,
      'data' => [ @max_slots, @items ]
    }.to_json(*a)

  end

  def self.json_create(o)
    new(*o['data'])
  end

end
