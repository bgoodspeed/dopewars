# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.join(File.dirname(__FILE__),'inventory')
class InsufficientMoneyException < Exception
  
end

class Hero
  extend Forwardable
  
  def_delegators :@character_attribution, :damage, :take_damage, :gain_experience, 
    :dead?, :status_info, :consume_item, :consume_level_up, :current_hp, :hp, 
    :hp_ratio, :equipment_info, :equip_in_slot_index
  def_delegators :@readiness_helper, :consume_readiness, :add_readiness, :ready?, :ready_ratio
  def_delegator :@readiness_helper, :points, :readiness_points

  attr_reader :money, :inventory, :name , :world_weapon
  def initialize(name="MAIN DUDE", world_weapon=nil, helper_start=1, helper_rate=1, attrib=nil)
    @name = name
    @readiness_helper = BattleReadinessHelper.new(helper_start, helper_rate)
    @character_attribution = attrib
    @world_weapon = world_weapon
  end

  include JsonHelper

  def json_params
    [@name, @world_weapon, @readiness_helper.starting_points, @readiness_helper.growth_rate, @character_attribution]
  end
end
