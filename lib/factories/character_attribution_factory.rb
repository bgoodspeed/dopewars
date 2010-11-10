# To change this template, choose Tools | Templates
# and open the template in the editor.

class CharacterAttributionFactory
  def initialize
    
  end

  def make_attribution(attributes=make_attributes)
    CharacterAttribution.new(
       CharacterState.new(attributes),
       EquipmentHolder.new)
  end

  def make_attributes
    CharacterAttributes.new(5, 5, 1, 0, 0, 0, 0, 0)
  end
end
