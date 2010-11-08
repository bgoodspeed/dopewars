# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseBattleItemBattleMenuAction < BattleMenuAction
  def initialize(game)
    super(game,"Items" ,[BattleFilteredInventoryMenuSelector.new(game)])
  end
end
