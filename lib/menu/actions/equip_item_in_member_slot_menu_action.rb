# To change this template, choose Tools | Templates
# and open the template in the editor.

class EquipItemInMemberSlotMenuAction
   attr_reader :dependencies, :name, :game
   include SelectorDependencyHelper


  def initialize(game)
    @game = game
    @name = "Equipment"
    @dependencies = [
      PartyMenuSelector.new(game),
      FilteredInventoryMenuSelector.new(game),
      EquipmentSlotMenuSelector.new(game)
    ]
  end


end
