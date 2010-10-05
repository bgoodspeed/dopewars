# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.join(File.dirname(__FILE__),'inventory')
class InsufficientMoneyException < Exception
  
end

class Hero

  attr_reader :money
  def initialize
    @inventory = Inventory.new(20)
    @money = 0
  end

  def free_inventory_slots
    @inventory.free_slots
  end

  def earn(amount)
    @money += amount
  end

  def spend(amount)
    raise InsufficientMoneyException if amount > @money
    @money -= amount
  end

  def quantity_of(drug)
    @inventory.quantity_of(drug)
  end

  def acquire_drug(drug, quantity)
    @inventory.add_item(quantity, drug)
  end

  def remove_drug(drug, quantity)
    @inventory.remove_item(quantity, drug)
  end
end
