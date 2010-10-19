
class CharacterAttributes
  attr_accessor :hp, :mp, :strength, :defense, :magic_power, :magic_defense, :agility, :luck
  def initialize(hp,mp, strength, defense, magic_power, magic_defense, agility, luck)
    @hp = hp
    @mp = mp
    @strength = strength
    @defense = defense
    @magic_power = magic_power
    @magic_defense = magic_defense
    @agility = agility
    @luck = luck
  end

  def add_attributes(other)
    @hp += other.hp
    @mp += other.mp
    @strength += other.strength
    @defense += other.defense
    @magic_power += other.magic_power
    @magic_defense += other.magic_defense
    @agility += other.agility
    @luck += other.luck
  end

  include JsonHelper
  def json_params
    [@hp,@mp, @strength, @defense, @magic_power, @magic_defense, @agility, @luck ]
  end
end
