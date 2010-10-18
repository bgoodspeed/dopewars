# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.join(File.dirname(__FILE__),'inventory')
class InsufficientMoneyException < Exception
  
end

class Hero
  extend Forwardable
  
  def_delegators :@character_attribution, :damage, :take_damage, :gain_experience, 
    :dead?, :status_info, :consume_item, :consume_level_up, :current_hp, :hp, :hp_ratio
  def_delegators :@readiness_helper, :consume_readiness, :add_readiness, :ready?, :ready_ratio

  attr_reader :money, :inventory, :name 
  def initialize(name="MAIN DUDE", helper_start=1, helper_rate=1, attrib=nil)
    @name = name
    @readiness_helper = BattleReadinessHelper.new(helper_start, helper_rate)
    @character_attribution = attrib
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

  alias_method :add_item, :acquire_drug

  def to_json(*a)
     {
      'json_class' => self.class.name,
      'data' => [ @name, @readiness_helper.starting_points, @readiness_helper.growth_rate, @character_attribution ]
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end
end
