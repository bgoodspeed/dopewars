
class CharacterAttribution
  extend Forwardable
  def_delegators :@state, :dead?, :take_damage, :damage, :gain_experience, :experience, :current_hp, :hp, :hp_ratio
  def_delegators :@equipment, :equipment_info, :equip_in_slot_index

  def initialize(state, equipment)
    @state = state
    @equipment = equipment
  end

  def consume_item(item)
    @state.add_effects(item.effects)
    item.consumed
  end

  def consume_level_up(attr_idx) #TODO this might not be the best way to pass this?
    bonus = 1
    cost = 1
    #TODO 1:1 level-stat tradeoff is not valid

    arr = 0.upto(7).collect {|n| n == attr_idx ? bonus : 0}
    @state.add_attributes(CharacterAttributes.new(*arr))
    @state.subtract_level_points(cost)
  end


  def stats_ordering
    [:hp, :mp, :exp, :lvp]
  end

  def stats_mapping
    m = {}
    m[:hp] = "HP: #{@state.current_hp}/#{@state.hp}"
    m[:mp] = "MP: #{@state.current_mp}/#{@state.mp}"
    m[:exp] = "EXP: #{@state.experience}"
    m[:lvp] = "LVP: #{@state.level_points}"
    m
  end

  def status_info
    stats_ordering.collect {|sk| stats_mapping[sk]}
  end
  include JsonHelper
  def json_params
    [ @state]
  end
end
