
class CharacterState
  attr_accessor :current_hp, :current_mp, :status_effects, :experience, :level_points, :attributes
  extend Forwardable
  def_delegators :@attributes, :hp, :mp, :add_attributes
  def initialize(attributes, exp=nil, chp=nil, cmp=nil, statii=nil, lvp=nil)
    @attributes = attributes
    @current_hp = chp.nil? ? attributes.hp : chp
    @current_mp = cmp.nil? ? attributes.mp : cmp
    @status_effects = statii.nil? ? [] : statii
    @experience = exp.nil? ? 0 : exp
    @level_points = lvp.nil? ? 0 : lvp
  end

  def dead?
    @current_hp <= 0
  end

  def take_damage(damage)
    @current_hp -= damage
  end
  def damage
    #TODO this should be a more complex formula than just Str :)
    @attributes.strength
  end

  def gain_experience(pts)
    @experience += pts
  end
  def hp_ratio
    @current_hp.to_f/@attributes.hp.to_f
  end

  def subtract_level_points(pts)
    @level_points -= pts
  end
  def add_effects(other_state)
    @current_hp += other_state.current_hp
    @current_mp += other_state.current_mp
    #TODO status effects, core attributes, etc

  end

  include JsonHelper
  def json_params
    [ @attributes, @experience, @current_hp, @current_mp, @status_effects]
  end

end
