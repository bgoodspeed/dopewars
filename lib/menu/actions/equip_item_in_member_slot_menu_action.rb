# To change this template, choose Tools | Templates
# and open the template in the editor.

class EquipItemInMemberSlotMenuAction < MenuAction

  def initialize(game)
    super(game,
          "Equipment",
          [ PartyMenuSelector.new(game),
            FilteredInventoryMenuSelector.new(game),
            EquipmentSlotMenuSelector.new(game)])
        
  end


end
